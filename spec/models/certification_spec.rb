require "rails_helper"

RSpec.describe Certification, type: :model do
  let(:user) { User.create!(name: "テスト", email: "spec@example.com", password: "password123") }

  def build_cert(exam_days_from_now: 30, created_days_ago: 0, target_minutes: 300)
    cert = user.certifications.new(
      name: "テスト資格",
      exam_date: Date.current + exam_days_from_now,
      target_minutes: target_minutes
    )
    cert.save!(validate: false)
    if created_days_ago > 0
      cert.update_column(:created_at, created_days_ago.days.ago)
    end
    cert
  end

  # ---------------------------------------------------------------
  # total_studied_minutes
  # ---------------------------------------------------------------
  describe "#total_studied_minutes" do
    it "study_logs がない場合は 0 を返す" do
      cert = build_cert
      allow(cert).to receive_message_chain(:study_logs, :sum).with(:studied_minutes).and_return(0)
      expect(cert.total_studied_minutes).to eq(0)
    end

    it "study_logs の studied_minutes の合計を返す" do
      cert = build_cert
      allow(cert).to receive_message_chain(:study_logs, :sum).with(:studied_minutes).and_return(180)
      expect(cert.total_studied_minutes).to eq(180)
    end
  end

  # ---------------------------------------------------------------
  # elapsed_days
  # ---------------------------------------------------------------
  describe "#elapsed_days" do
    it "登録当日は 0 を返す" do
      cert = build_cert
      expect(cert.elapsed_days).to eq(0)
    end

    it "10日前に登録した場合は 10 を返す" do
      cert = build_cert(created_days_ago: 10)
      expect(cert.elapsed_days).to eq(10)
    end
  end

  # ---------------------------------------------------------------
  # total_days
  # ---------------------------------------------------------------
  describe "#total_days" do
    it "登録日から試験日までの日数を返す" do
      cert = build_cert(exam_days_from_now: 30, created_days_ago: 0)
      expect(cert.total_days).to eq(30)
    end

    it "登録10日後に試験がある場合は差分を返す" do
      cert = build_cert(exam_days_from_now: 20, created_days_ago: 10)
      expect(cert.total_days).to eq(30)
    end
  end

  # ---------------------------------------------------------------
  # pace_status
  # ---------------------------------------------------------------
  describe "#pace_status" do
    context "登録当日（elapsed_days = 0）の場合" do
      it ":on_track を返す" do
        cert = build_cert
        expect(cert.pace_status).to eq(:on_track)
      end
    end

    context "ratio >= 0.9 の場合" do
      it ":on_track を返す（ちょうど 0.9）" do
        cert = build_cert(target_minutes: 100, created_days_ago: 10, exam_days_from_now: 20)
        # total_days=30, elapsed=10, expected=100*(10/30)=33.3, ratio=0.9 → studied=30
        allow(cert).to receive(:total_studied_minutes).and_return(30)
        expect(cert.pace_status).to eq(:on_track)
      end

      it ":on_track を返す（ratio > 0.9）" do
        cert = build_cert(target_minutes: 100, created_days_ago: 10, exam_days_from_now: 20)
        allow(cert).to receive(:total_studied_minutes).and_return(40)
        expect(cert.pace_status).to eq(:on_track)
      end
    end

    context "0.6 <= ratio < 0.9 の場合" do
      it ":caution を返す（ちょうど 0.6）" do
        cert = build_cert(target_minutes: 100, created_days_ago: 10, exam_days_from_now: 20)
        # expected=33.3, ratio=0.6 → studied=20
        allow(cert).to receive(:total_studied_minutes).and_return(20)
        expect(cert.pace_status).to eq(:caution)
      end

      it ":caution を返す（ratio = 0.75）" do
        cert = build_cert(target_minutes: 100, created_days_ago: 10, exam_days_from_now: 20)
        allow(cert).to receive(:total_studied_minutes).and_return(25)
        expect(cert.pace_status).to eq(:caution)
      end
    end

    context "ratio < 0.6 の場合" do
      it ":behind を返す" do
        cert = build_cert(target_minutes: 100, created_days_ago: 10, exam_days_from_now: 20)
        allow(cert).to receive(:total_studied_minutes).and_return(10)
        expect(cert.pace_status).to eq(:behind)
      end

      it ":behind を返す（学習ゼロ）" do
        cert = build_cert(target_minutes: 100, created_days_ago: 10, exam_days_from_now: 20)
        allow(cert).to receive(:total_studied_minutes).and_return(0)
        expect(cert.pace_status).to eq(:behind)
      end
    end
  end

  # ---------------------------------------------------------------
  # daily_quota_minutes
  # ---------------------------------------------------------------
  describe "#daily_quota_minutes" do
    it "残り日数・未達成の場合は ceil した値を返す" do
      cert = build_cert(target_minutes: 300, exam_days_from_now: 30)
      allow(cert).to receive(:total_studied_minutes).and_return(0)
      # 300 / 30 = 10
      expect(cert.daily_quota_minutes).to eq(10)
    end

    it "割り切れない場合は切り上げる" do
      cert = build_cert(target_minutes: 100, exam_days_from_now: 30)
      allow(cert).to receive(:total_studied_minutes).and_return(0)
      # 100 / 30 = 3.33... → ceil = 4
      expect(cert.daily_quota_minutes).to eq(4)
    end

    it "学習済み分数を差し引いて計算する" do
      cert = build_cert(target_minutes: 300, exam_days_from_now: 30)
      allow(cert).to receive(:total_studied_minutes).and_return(120)
      # (300-120) / 30 = 6
      expect(cert.daily_quota_minutes).to eq(6)
    end

    it "目標達成済みの場合は 0 を返す" do
      cert = build_cert(target_minutes: 300, exam_days_from_now: 30)
      allow(cert).to receive(:total_studied_minutes).and_return(300)
      expect(cert.daily_quota_minutes).to eq(0)
    end

    it "目標を超過している場合は 0 を返す" do
      cert = build_cert(target_minutes: 300, exam_days_from_now: 30)
      allow(cert).to receive(:total_studied_minutes).and_return(400)
      expect(cert.daily_quota_minutes).to eq(0)
    end
  end

  # ---------------------------------------------------------------
  # remaining_days
  # ---------------------------------------------------------------
  describe "#remaining_days" do
    it "試験日まで30日ある場合は30を返す" do
      cert = build_cert(exam_days_from_now: 30)
      expect(cert.remaining_days).to eq(30)
    end

    it "試験日まで1日の場合は1を返す" do
      cert = build_cert(exam_days_from_now: 1)
      expect(cert.remaining_days).to eq(1)
    end
  end

  # ---------------------------------------------------------------
  # achievement_rate
  # ---------------------------------------------------------------
  describe "#achievement_rate" do
    it "学習ゼロの場合は0を返す" do
      cert = build_cert(target_minutes: 300)
      allow(cert).to receive(:total_studied_minutes).and_return(0)
      expect(cert.achievement_rate).to eq(0)
    end

    it "50%達成している場合は50を返す" do
      cert = build_cert(target_minutes: 300)
      allow(cert).to receive(:total_studied_minutes).and_return(150)
      expect(cert.achievement_rate).to eq(50)
    end

    it "目標を超過しても100を上限とする" do
      cert = build_cert(target_minutes: 300)
      allow(cert).to receive(:total_studied_minutes).and_return(400)
      expect(cert.achievement_rate).to eq(100)
    end

    it "小数は切り捨てる" do
      cert = build_cert(target_minutes: 300)
      allow(cert).to receive(:total_studied_minutes).and_return(100)
      # 100/300 = 33.3... → 33
      expect(cert.achievement_rate).to eq(33)
    end
  end

  after(:each) do
    user.destroy
  end
end

require "rails_helper"

RSpec.describe StudyLog, type: :model do
  let(:user) { User.create!(name: "テスト", email: "sl_spec@example.com", password: "password123") }
  let(:certification) do
    user.certifications.create!(
      name: "テスト資格",
      exam_date: 30.days.from_now.to_date,
      target_minutes: 300
    )
  end

  def valid_log
    certification.study_logs.new(studied_minutes: 60, logged_on: Date.current)
  end

  describe "アソシエーション" do
    it "certificationに属している" do
      log = valid_log
      expect(log.certification).to eq(certification)
    end
  end

  describe "バリデーション" do
    it "有効なデータで保存できる" do
      expect(valid_log).to be_valid
    end

    it "memoなしでも保存できる" do
      log = certification.study_logs.new(studied_minutes: 60, logged_on: Date.current, memo: "")
      expect(log).to be_valid
    end

    context "studied_minutes" do
      it "空の場合は無効" do
        log = certification.study_logs.new(logged_on: Date.current)
        expect(log).not_to be_valid
        expect(log.errors[:studied_minutes]).to be_present
      end

      it "0の場合は無効" do
        log = certification.study_logs.new(studied_minutes: 0, logged_on: Date.current)
        expect(log).not_to be_valid
      end

      it "負の値の場合は無効" do
        log = certification.study_logs.new(studied_minutes: -1, logged_on: Date.current)
        expect(log).not_to be_valid
      end

      it "1以上の整数は有効" do
        log = certification.study_logs.new(studied_minutes: 1, logged_on: Date.current)
        expect(log).to be_valid
      end
    end

    context "logged_on" do
      it "空の場合は無効" do
        log = certification.study_logs.new(studied_minutes: 60)
        expect(log).not_to be_valid
        expect(log.errors[:logged_on]).to be_present
      end
    end
  end

  after(:each) { user.destroy }
end

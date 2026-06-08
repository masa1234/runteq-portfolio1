require "test_helper"

class CertificationTest < ActiveSupport::TestCase
  def setup
    @certification = Certification.new(
      name: "基本情報技術者試験",
      exam_date: 30.days.from_now.to_date,
      target_minutes: 6000,
      user: users(:one)
    )
  end

  test "valid with all attributes present" do
    assert @certification.valid?
  end

  test "invalid without a name" do
    @certification.name = nil
    assert_not @certification.valid?
    assert_includes @certification.errors[:name], "can't be blank"
  end

  test "invalid without an exam_date" do
    @certification.exam_date = nil
    assert_not @certification.valid?
    assert_includes @certification.errors[:exam_date], "can't be blank"
  end

  test "invalid when exam_date is today" do
    @certification.exam_date = Date.current
    assert_not @certification.valid?
    assert_includes @certification.errors[:exam_date], "must be a date in the future"
  end

  test "invalid when exam_date is in the past" do
    @certification.exam_date = 1.day.ago.to_date
    assert_not @certification.valid?
    assert_includes @certification.errors[:exam_date], "must be a date in the future"
  end

  test "invalid without target_minutes" do
    @certification.target_minutes = nil
    assert_not @certification.valid?
    assert_includes @certification.errors[:target_minutes], "can't be blank"
  end

  test "invalid when target_minutes is not a number" do
    @certification.target_minutes = "abc"
    assert_not @certification.valid?
    assert_includes @certification.errors[:target_minutes], "is not a number"
  end

  test "invalid when target_minutes is zero or negative" do
    @certification.target_minutes = 0
    assert_not @certification.valid?
    assert_includes @certification.errors[:target_minutes], "must be greater than 0"
  end

  test "invalid without a user" do
    @certification.user = nil
    assert_not @certification.valid?
    assert_includes @certification.errors[:user], "must exist"
  end
end

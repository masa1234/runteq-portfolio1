class Certification < ApplicationRecord
  belongs_to :user
  has_many :study_logs

  validates :name, presence: true
  validates :exam_date, presence: true
  validates :target_minutes, presence: true, numericality: { only_integer: true, greater_than: 0 }

  validate :exam_date_must_be_in_the_future

  def total_studied_minutes
    study_logs.sum(:studied_minutes)
  end

  def elapsed_days
    (Date.current - created_at.to_date).to_i
  end

  def total_days
    (exam_date - created_at.to_date).to_i
  end

  def pace_status
    return :on_track if elapsed_days.zero?

    expected = target_minutes * (elapsed_days.to_f / total_days)
    return :on_track if expected.zero?

    ratio = total_studied_minutes / expected
    if ratio >= 0.9
      :on_track
    elsif ratio >= 0.6
      :caution
    else
      :behind
    end
  end

  def daily_quota_minutes
    remaining_days = (exam_date - Date.current).to_i
    return 0 if remaining_days <= 0

    remaining_minutes = target_minutes - total_studied_minutes
    return 0 if remaining_minutes <= 0

    (remaining_minutes.to_f / remaining_days).ceil
  end

  private

  def exam_date_must_be_in_the_future
    return if exam_date.blank?

    if exam_date <= Date.current
      errors.add(:exam_date, "must be a date in the future")
    end
  end
end

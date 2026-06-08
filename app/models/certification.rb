class Certification < ApplicationRecord
  belongs_to :user
  has_many :study_logs

  validates :name, presence: true
  validates :exam_date, presence: true
  validates :target_minutes, presence: true, numericality: { only_integer: true, greater_than: 0 }

  validate :exam_date_must_be_in_the_future

  private

  def exam_date_must_be_in_the_future
    return if exam_date.blank?

    if exam_date <= Date.current
      errors.add(:exam_date, "must be a date in the future")
    end
  end
end

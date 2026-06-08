class StudyLog < ApplicationRecord
  belongs_to :certification

  validates :studied_minutes, presence: true,
                               numericality: { only_integer: true, greater_than: 0 }
  validates :logged_on, presence: true
end

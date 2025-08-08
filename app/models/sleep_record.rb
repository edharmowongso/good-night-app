class SleepRecord < ApplicationRecord
  include TimeHelper
  
  belongs_to :user

  validates :bedtime, presence: true
  validates :duration_minutes, presence: true, if: :wake_time?
  validates :score, inclusion: { in: 1..5 }, allow_nil: true
  validate :wake_time_after_bedtime, if: :wake_time?

  enum status: { incomplete: 0, completed: 1, cancelled: 2 }
  
  before_create :set_jakarta_timezone
  before_save :set_sleep_date

  def initialize(attributes = {})
    super
    self.status ||= :incomplete
    self.bedtime ||= get_current_time_without_str('Asia/Jakarta')
    self.created_at ||= get_current_time_without_str('Asia/Jakarta')
    self.updated_at ||= get_current_time_without_str('Asia/Jakarta')
  end

  scope :last_week, -> { 
    jakarta_time = Time.current.in_time_zone('Asia/Jakarta')
    one_week_ago = jakarta_time - 1.week
    where(created_at: one_week_ago..jakarta_time) 
  }
  scope :by_duration, -> { order(duration_minutes: :desc) }

  def quality_text
    return nil unless score
    %w[Terrible Poor Fair Good Excellent][score - 1]
  end

  def duration_hours
    return nil unless duration_minutes
    (duration_minutes / 60.0).round(2)
  end

  private

  def set_jakarta_timezone
    self.bedtime = get_current_time_without_str('Asia/Jakarta') if bedtime.blank?
  end

  def set_sleep_date
    if bedtime.present?
      # Set sleep_date based on bedtime in Jakarta timezone
      jakarta_time = bedtime.in_time_zone('Asia/Jakarta')
      self.sleep_date = jakarta_time.to_date
    end
  end

  def wake_time_after_bedtime
    return unless wake_time && bedtime

    if wake_time <= bedtime
      errors.add(:wake_time, "must be after bedtime")
    end
  end
end

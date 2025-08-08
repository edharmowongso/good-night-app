class SleepRecords::ClockInService < ApplicationService
  include TimeHelper
  
  def initialize(user, bedtime = nil)
    @user = user
    @bedtime = bedtime || get_current_time_without_str('Asia/Jakarta')
  end

  def call
    ActiveRecord::Base.transaction do
      complete_previous_record if previous_incomplete_record
      create_new_record
    end
  rescue ActiveRecord::RecordInvalid => e
    failure(e.message)
  end

  private

  attr_reader :user, :bedtime

  def complete_previous_record
    previous_record = previous_incomplete_record
    return unless previous_record

    wake_time = bedtime
    duration = calculate_duration(previous_record.bedtime, wake_time)
    
    previous_record.update!(
      wake_time: wake_time,
      duration_minutes: duration,
      status: :completed
    )
  end

  def create_new_record
    sleep_record = user.sleep_records.create!(
      bedtime: bedtime,
      status: :incomplete
    )
    
    # Return all user's sleep records for API response
    all_records = user.sleep_records.includes(:user).order(:created_at)
    success(sleep_records: all_records)
  end

  def previous_incomplete_record
    @previous_incomplete_record ||= user.sleep_records
                                         .incomplete
                                         .order(:created_at)
                                         .last
  end

  def calculate_duration(start_time, end_time)
    ((end_time - start_time) / 1.minute).round
  end
end

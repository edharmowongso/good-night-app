class SleepRecords::UpdateService < ApplicationService
  include TimeHelper
  
  def initialize(sleep_record, params)
    @sleep_record = sleep_record
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      update_record
    end
  rescue ActiveRecord::RecordInvalid => e
    failure(e.message)
  end

  private

  attr_reader :sleep_record, :params

  def update_record
    # Handle status change logic
    if params[:status] == 'cancelled'
      cancel_record
    elsif params[:status] == 'completed' && sleep_record.incomplete?
      complete_record
    else
      update_attributes
    end

    success(sleep_record: sleep_record.reload)
  end

  def cancel_record
    sleep_record.update!(
      status: :cancelled,
      wake_time: nil,
      duration_minutes: nil
    )
  end

  def complete_record
    wake_time = if params[:wake_time].present?
                  params[:wake_time].in_time_zone('Asia/Jakarta')
                else
                  get_current_time_without_str('Asia/Jakarta')
                end
    duration = calculate_duration(sleep_record.bedtime, wake_time)
    
    sleep_record.update!(
      status: :completed,
      wake_time: wake_time,
      duration_minutes: duration,
      score: params[:score],
      notes: params[:notes]
    )
  end

  def update_attributes
    update_params = params.slice(:score, :notes)
    update_params[:status] = params[:status] if params[:status].present?
    
    sleep_record.update!(update_params)
  end

  def calculate_duration(start_time, end_time)
    ((end_time - start_time) / 1.minute).round
  end
end

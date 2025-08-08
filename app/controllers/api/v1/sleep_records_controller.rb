class Api::V1::SleepRecordsController < Api::V1::BaseController
  include TimeHelper
  
  def index
    sleep_records = current_user.sleep_records.includes(:user).order(:created_at)
    render json: serialize_collection(sleep_records, SleepRecordSerializer)
  end

  def create
    validated_params = validate_with_contract(SleepRecords::CreateContract, params)
    
    bedtime = if validated_params[:bedtime].present?
                validated_params[:bedtime].in_time_zone('Asia/Jakarta')
              else
                get_current_time_without_str('Asia/Jakarta')
              end
    
    result = SleepRecords::ClockInService.call(current_user, bedtime)

    if result.success?
      render json: serialize_collection(result.data[:sleep_records], SleepRecordSerializer), status: :created
    else
      render_error(result.error)
    end
  end

  def update
    sleep_record = current_user.sleep_records.find(params[:id])
    validated_params = validate_with_contract(SleepRecords::UpdateContract, params)
    
    result = SleepRecords::UpdateService.call(sleep_record, validated_params)
    
    if result.success?
      render json: serialize_object(result.data[:sleep_record], SleepRecordSerializer)
    else
      render_error(result.error)
    end
  end

  def following_records
    records = current_user.following_sleep_records_last_week
    render json: serialize_collection(records, SleepRecordSerializer)
  end
end

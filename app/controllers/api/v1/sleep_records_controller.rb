class Api::V1::SleepRecordsController < Api::V1::BaseController
  include TimeHelper
  
  def index
    validated_params = validate_with_contract(SleepRecords::IndexContract, params)
    
    per_page = (validated_params[:per_page] || 20).to_i.clamp(1, 100)
    sleep_records = current_user.sleep_records.includes(:user)

    sleep_records = apply_date_filter(sleep_records, validated_params[:filter]) if validated_params[:filter]
    
    sleep_records = sleep_records.order(created_at: :desc)
                                 .page(validated_params[:page])
                                 .per(per_page)
    
    render json: {
      sleep_records: serialize_collection(sleep_records, SleepRecordSerializer),
      pagination: pagination_meta(sleep_records),
      filters: validated_params[:filter] || {}
    }
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
    per_page = (params[:per_page] || 20).to_i.clamp(1, 100)
    
    # Get cached records and paginate them
    all_records = current_user.following_sleep_records_last_week
    paginated_records = Kaminari.paginate_array(all_records)
                                .page(params[:page])
                                .per(per_page)
    
    render json: {
      sleep_records: serialize_collection(paginated_records, SleepRecordSerializer),
      pagination: pagination_meta(paginated_records)
    }
  end

  private

  def apply_date_filter(records, filter)
    return records unless filter

    if filter[:date_from].present?
      date_from = Date.parse(filter[:date_from])
      records = records.where('sleep_date >= ?', date_from)
    end

    if filter[:date_to].present?
      date_to = Date.parse(filter[:date_to])
      records = records.where('sleep_date <= ?', date_to)
    end

    if filter[:status].present?
      records = records.where(status: filter[:status])
    end

    records
  end
end

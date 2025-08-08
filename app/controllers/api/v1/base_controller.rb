class Api::V1::BaseController < ApplicationController
  include ActionController::RequestForgeryProtection
  include Contractable
  include Serializable
  include TimeHelper

  rescue_from UnauthorizedError, with: :handle_unauthorized_error
  rescue_from CustomError, with: :handle_custom_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
  
  protect_from_forgery with: :null_session
  before_action :set_current_user

  private

  def set_current_user
    user_id = request.headers['X-User-ID'] || params[:user_id]
    @current_user = User.find_by(id: user_id) if user_id.present?
    
    raise UnauthorizedError unless @current_user
  end

  def current_user
    @current_user
  end

  def render_error(message, status = :unprocessable_entity)
    render json: { 
      error_type: 'validation_error',
      message: message 
    }, status: status
  end

  def handle_custom_error(exception)
    render json: {
      error_type: exception.error_type,
      message: exception.message
    }, status: http_status_for_error(exception.error_type)
  end

  def handle_not_found(exception)
    render json: {
      error_type: 'not_found',
      message: I18n.t('errors.custom_errors.not_found')
    }, status: :not_found
  end

  def handle_invalid_record(exception)
    render json: {
      error_type: 'validation_error',
      message: exception.record.errors.full_messages.join(', ')
    }, status: :unprocessable_entity
  end

  def handle_standard_error(exception)
    Rails.logger.error "Unhandled error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    
    render json: {
      error_type: 'internal_server_error',
      message: I18n.t('errors.custom_errors.internal_server_error')
    }, status: :internal_server_error
  end

  def handle_unauthorized_error(exception)
    binding.pry
    render json: {
      error_type: 'unauthorized',
      message: I18n.t('errors.custom_errors.unauthorized')
    }, status: :unauthorized
  end

  def http_status_for_error(error_type)
    case error_type.to_s
    when 'bad_request' then :bad_request
    when 'unauthorized' then :unauthorized
    when 'forbidden' then :forbidden
    when 'not_found' then :not_found
    when 'unprocessable_entity' then :unprocessable_entity
    when 'internal_server_error' then :internal_server_error
    when 'service_unavailable' then :service_unavailable
    else :unprocessable_entity
    end
  end
end

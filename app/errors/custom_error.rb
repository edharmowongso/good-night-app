class CustomError < StandardError
  attr_reader :error_type, :message

  def initialize(error_type = 'custom_error', message = nil)
    @error_type = error_type
    @message = message || I18n.t("errors.custom_errors.#{error_type}", default: 'Something went wrong')
    super(@message)
    log_error
  end

  private

  def log_error
    Rails.logger.error(
      error_type: @error_type,
      message: @message,
      backtrace: backtrace&.first(5)
    )
  end
end

module Contractable
  extend ActiveSupport::Concern

  private

  def validate_with_contract(contract_class, request_params = params, **options)
    current_user_context = options[:current_user] || current_user
    
    # Convert params to hash safely
    params_hash = request_params.respond_to?(:permit!) ? request_params.permit!.to_h : request_params.to_h
    
    # Create contract instance with current_user option if needed
    if contract_class.method_defined?(:current_user)
      result = contract_class.new(current_user: current_user_context).call(params_hash)
    else
      result = contract_class.call(params_hash)
    end

    unless result.success?
      error_messages = format_validation_errors(result.errors.to_h)
      raise BadRequestError, error_messages
    end

    result.to_h
  end

  def format_validation_errors(errors_hash)
    errors_hash.map do |key, messages|
      Array(messages).map do |message|
        "#{key.to_s.humanize}: #{message}"
      end
    end.flatten.join('; ')
  end
end

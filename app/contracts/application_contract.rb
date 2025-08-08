require 'dry/validation'

class ApplicationContract < Dry::Validation::Contract
  # Common validation methods and rules can go here
  
  def self.call(params)
    new.call(params)
  end
  
  private
  
  # Custom predicates for reuse across contracts
  def future_date?(value)
    return false unless value.is_a?(Time) || value.is_a?(DateTime)
    value <= Time.current
  end
  
  def valid_timezone?(value)
    return true if value.blank?
    ActiveSupport::TimeZone[value].present?
  rescue
    false
  end
end

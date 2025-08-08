class SleepRecords::CreateContract < ApplicationContract
  params do
    optional(:bedtime).maybe(:string)
    optional(:timezone).maybe(:string)
  end

  rule(:bedtime) do
    if value.present?
      begin
        parsed_time = Time.zone.parse(value)
        if parsed_time.nil?
          key.failure('invalid datetime format')
        elsif parsed_time > Time.current + 1.hour
          key.failure('cannot be more than 1 hour in the future')
        elsif parsed_time < 1.year.ago
          key.failure('cannot be more than 1 year ago')
        end
      rescue ArgumentError, TypeError
        key.failure('invalid datetime format. Use ISO 8601 format (e.g., 2023-08-08T22:00:00Z)')
      end
    end
  end

  rule(:timezone) do
    if value.present? && !valid_timezone?(value)
      key.failure('invalid timezone')
    end
  end

  # Cross-field validation
  rule(:bedtime, :timezone) do
    if values[:bedtime].present? && values[:timezone].present?
      begin
        Time.zone = values[:timezone]
        Time.zone.parse(values[:bedtime])
      rescue
        base.failure('bedtime and timezone combination is invalid')
      ensure
        Time.zone = Rails.application.config.time_zone
      end
    end
  end
end

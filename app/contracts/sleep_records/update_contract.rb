class SleepRecords::UpdateContract < ApplicationContract
  params do
    optional(:score).maybe(:integer)
    optional(:notes).maybe(:string)
    optional(:status).maybe(:string)
    optional(:wake_time).maybe(:string)
  end

  rule(:score) do
    if value.present? && (value < 1 || value > 5)
      key.failure('must be between 1 and 5')
    end
  end

  rule(:notes) do
    if value.present? && value.length > 1000
      key.failure('cannot be longer than 1000 characters')
    end
  end

  rule(:status) do
    if value.present? && !%w[incomplete completed cancelled].include?(value)
      key.failure('must be incomplete, completed, or cancelled')
    end
  end

  rule(:wake_time) do
    if value.present?
      begin
        parsed_time = Time.zone.parse(value)
        if parsed_time.nil?
          key.failure('invalid datetime format')
        elsif parsed_time > Time.current + 1.hour
          key.failure('cannot be more than 1 hour in the future')
        end
      rescue ArgumentError, TypeError
        key.failure('invalid datetime format. Use ISO 8601 format (e.g., 2023-08-08T08:00:00Z)')
      end
    end
  end
end

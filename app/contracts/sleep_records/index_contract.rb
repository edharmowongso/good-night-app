class SleepRecords::IndexContract < ApplicationContract
  params do
    optional(:page).filled(:integer)
    optional(:per_page).filled(:integer)
    optional(:filter).hash do
      optional(:date_from).filled(:string)
      optional(:date_to).filled(:string)
      optional(:status).filled(:string)
    end
  end

  rule(:page) do
    if value.present? && value < 1
      key.failure('must be greater than 0')
    end
  end

  rule(:per_page) do
    if value.present? && (value < 1 || value > 100)
      key.failure('must be between 1 and 100')
    end
  end

  rule('filter.date_from') do
    if value.present?
      begin
        Date.parse(value)
      rescue ArgumentError
        key.failure('must be a valid date format (YYYY-MM-DD)')
      end
    end
  end

  rule('filter.date_to') do
    if value.present?
      begin
        Date.parse(value)
      rescue ArgumentError
        key.failure('must be a valid date format (YYYY-MM-DD)')
      end
    end
  end

  rule('filter.date_from', 'filter.date_to') do
    if values['filter.date_from'].present? && values['filter.date_to'].present?
      begin
        date_from = Date.parse(values['filter.date_from'])
        date_to = Date.parse(values['filter.date_to'])
        if date_from > date_to
          key('filter.date_from').failure('must be before or equal to date_to')
        end
      rescue ArgumentError
        # Already handled by individual date validations
      end
    end
  end

  rule('filter.status') do
    if value.present?
      valid_statuses = %w[incomplete completed cancelled]
      unless valid_statuses.include?(value)
        key.failure("must be one of: #{valid_statuses.join(', ')}")
      end
    end
  end
end

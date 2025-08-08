class Users::IndexContract < ApplicationContract
  params do
    optional(:page).filled(:integer)
    optional(:per_page).filled(:integer)
    optional(:search).filled(:string)
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

  rule(:search) do
    if value.present?
      if value.length < 2
        key.failure('must be at least 2 characters long')
      elsif value.length > 50
        key.failure('must be less than 50 characters')
      elsif value.match?(/[<>{}]/)
        key.failure('contains invalid characters')
      end
    end
  end
end

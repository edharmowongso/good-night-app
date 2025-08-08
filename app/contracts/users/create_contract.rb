class Users::CreateContract < ApplicationContract
  params do
    required(:user).hash do
      required(:name).filled(:string)
      required(:username).filled(:string)
    end
  end

  rule('user.name') do
    key.failure(I18n.t('errors.models.user.attributes.name.blank')) if value.blank?
    
    if value.present?
      if value.length < 2
        key.failure('must be at least 2 characters long')
      elsif value.length > 50
        key.failure('must be less than 50 characters')
      elsif value.match?(/\A[0-9]+\z/)
        key.failure('cannot be only numbers')
      elsif value.match?(/[<>{}]/)
        key.failure('contains invalid characters')
      end
      
    end
  end

  rule('user.username') do
    key.failure('username cannot be blank') if value.blank?
    
    if value.present?
      if value.length < 3
        key.failure('must be at least 3 characters long')
      elsif value.length > 20
        key.failure('must be less than 20 characters')
      elsif !value.match?(/\A[a-zA-Z0-9_]+\z/)
        key.failure('only allows letters, numbers, and underscores')
      elsif value.match?(/\A[0-9_]+\z/)
        key.failure('must contain at least one letter')
      end
      
      # Check uniqueness
      if User.exists?(username: value)
        key.failure('username has already been taken')
      end
    end
  end
end

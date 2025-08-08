module Follows
  class CreateContract < ApplicationContract
  option :current_user, optional: true

  params do
    required(:followed_id).filled(:integer)
  end

  rule(:followed_id) do
    if value.present?
      if value <= 0
        key.failure('must be a positive integer')
      else
        # Check if user exists
        unless User.exists?(id: value)
          key.failure(I18n.t('api.v1.follows.errors.user_not_found'))
        end
      end
    end
  end

  rule(:followed_id) do
    if current_user && value.present? && value == current_user.id
      key.failure(I18n.t('api.v1.follows.errors.cannot_follow_self'))
    end
  end

  rule(:followed_id) do
    if current_user && value.present? && User.exists?(id: value)
      if current_user.following?(User.find(value))
        key.failure(I18n.t('api.v1.follows.errors.already_following'))
      end
    end
  end
  end
end

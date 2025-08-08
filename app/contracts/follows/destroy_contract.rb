module Follows
  class DestroyContract < ApplicationContract
    option :current_user, optional: true

    params do
      required(:id).filled(:integer)
    end

    rule(:id) do
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

    rule(:id) do
      if current_user && value.present? && value == current_user.id
        key.failure('Cannot unfollow yourself')
      end
    end

    rule(:id) do
      if current_user && value.present? && User.exists?(id: value)
        unless current_user.following?(User.find(value))
          key.failure(I18n.t('api.v1.follows.errors.not_following'))
        end
      end
    end
  end
end

class Follows::DestroyService < ApplicationService
  def initialize(follower, followed)
    @follower = follower
    @followed = followed
  end

  def call
    ActiveRecord::Base.transaction do
      validate_unfollow_request
      destroy_follow
    end
  rescue ActiveRecord::RecordInvalid => e
    failure(e.message)
  end

  private

  attr_reader :follower, :followed

  def validate_unfollow_request
    unless follower.following?(followed)
      raise BadRequestError, I18n.t('api.v1.follows.errors.not_following')
    end
  end

  def destroy_follow
    if follower.unfollow(followed)
      success(
        message: I18n.t('api.v1.follows.success.unfollowed', name: followed.name),
        unfollowed: followed
      )
    else
      failure('Unable to unfollow user')
    end
  end
end

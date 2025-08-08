class Follows::CreateService < ApplicationService
  def initialize(follower, followed)
    @follower = follower
    @followed = followed
  end

  def call
    validate_follow_request
    create_follow
  end

  private

  attr_reader :follower, :followed

  def validate_follow_request
    if follower == followed
      raise BadRequestError, I18n.t('api.v1.follows.errors.cannot_follow_self')
    end

    if follower.following?(followed)
      raise BadRequestError, I18n.t('api.v1.follows.errors.already_following')
    end
  end

  def create_follow
    follow = follower.follow(followed)
    
    if follow.persisted?
      success(
        message: I18n.t('api.v1.follows.success.followed', name: followed.name),
        following: followed
      )
    else
      failure(follow.errors.full_messages.join(', '))
    end
  end
end

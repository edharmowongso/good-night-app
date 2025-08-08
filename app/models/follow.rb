class Follow < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'

  validates :follower_id, uniqueness: { scope: :followed_id }
  validate :cannot_follow_self

  after_commit :invalidate_caches, on: [:create, :destroy]

  def initialize(attributes = {})
    super(attributes)
    self.created_at ||= get_current_time_without_str('Asia/Jakarta')
    self.updated_at ||= get_current_time_without_str('Asia/Jakarta')
  end

  private

  def cannot_follow_self
    if follower_id == followed_id
      errors.add(:followed, "cannot follow yourself")
    end
  end

  def invalidate_caches
    # Invalidate follower's cache
    Rails.cache.delete("user_#{follower_id}_following_ids")
    Rails.cache.delete("user_#{follower_id}_leaderboard")
    
    # Invalidate followed user's cache (they might have different leaderboards)
    Rails.cache.delete("user_#{followed_id}_leaderboard") if followed_id
  end
end

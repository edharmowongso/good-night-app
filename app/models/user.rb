class User < ApplicationRecord
  validates :name, presence: true
  validates :username, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers, and underscores" }

  enum user_status: { active: 0, inactive: 1 }

  def initialize(attributes = {})
    super
    self.user_status ||= :active
    self.created_at ||= get_current_time_without_str('Asia/Jakarta')
    self.updated_at ||= get_current_time_without_str('Asia/Jakarta')
  end

  has_many :sleep_records, dependent: :destroy

  has_many :active_follows, class_name: 'Follow', foreign_key: 'follower_id', dependent: :destroy
  has_many :passive_follows, class_name: 'Follow', foreign_key: 'followed_id', dependent: :destroy

  has_many :following, through: :active_follows, source: :followed
  has_many :followers, through: :passive_follows, source: :follower

  def follow(other_user)
    return false if self == other_user
    result = active_follows.find_or_create_by(followed: other_user)
    invalidate_following_cache
    result
  end

  def unfollow(other_user)
    result = active_follows.find_by(followed: other_user)&.destroy
    invalidate_following_cache
    result
  end

  def following?(other_user)
    cached_following_ids.include?(other_user.id)
  end

  def following_sleep_records_last_week
    Rails.cache.fetch("user_#{id}_leaderboard", expires_in: 5.minutes) do
      following_ids = cached_following_ids
      return [] if following_ids.empty?

      one_week_ago = get_current_time_without_str('Asia/Jakarta') - 1.week
      current_time = get_current_time_without_str('Asia/Jakarta')
      SleepRecord.joins(:user)
                 .where(user_id: following_ids)
                 .where(created_at: one_week_ago..current_time)
                 .completed
                 .includes(:user)
                 .order(duration_minutes: :desc)
                 .limit(200)
                 .to_a
    end
  end

  private

  def cached_following_ids
    Rails.cache.fetch("user_#{id}_following_ids", expires_in: 15.minutes) do
      following.pluck(:id)
    end
  end

  def invalidate_following_cache
    Rails.cache.delete("user_#{id}_following_ids")
    Rails.cache.delete("user_#{id}_leaderboard")
  end
end

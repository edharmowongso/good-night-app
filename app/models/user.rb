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
    active_follows.find_or_create_by(followed: other_user)
  end

  def unfollow(other_user)
    active_follows.find_by(followed: other_user)&.destroy
  end

  def following?(other_user)
    following.include?(other_user)
  end

  def following_sleep_records_last_week
    following_ids = following.pluck(:id)
    return SleepRecord.none if following_ids.empty?

    one_week_ago = get_current_time_without_str('Asia/Jakarta') - 1.week
    current_time = get_current_time_without_str('Asia/Jakarta')
    SleepRecord.joins(:user)
               .where(user_id: following_ids)
               .where(created_at: one_week_ago..current_time)
               .completed
               .includes(:user)
               .order(duration_minutes: :desc)
  end
end

FactoryBot.define do
  factory :follow do
    association :follower, factory: :user
    association :followed, factory: :user

    initialize_with do
      follow = new(attributes)
      follow.created_at ||= Time.current.in_time_zone('Asia/Jakarta')
      follow.updated_at ||= Time.current.in_time_zone('Asia/Jakarta')
      follow
    end

    after(:build) do |follow|
      if follow.follower == follow.followed
        follow.followed = build(:user)
      end
    end
  end
end

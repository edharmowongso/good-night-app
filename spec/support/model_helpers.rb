module ModelHelpers
  # Helper to test time-sensitive records
  def travel_to_time(time)
    travel_to(time) { yield }
  end

  # Helper to create mocked user with followers
  def user_with_followers(follower_count = 3)
    user = instance_double(User, id: 1)
    followers = Array.new(follower_count) { |i| instance_double(User, id: i + 10) }
    
    allow(user).to receive(:followers).and_return(followers)
    allow(user).to receive(:total_followers).and_return(follower_count)
    
    user
  end

  # Helper to create mocked user with following relationships
  def user_with_following(total_following = 3)
    user = instance_double(User, id: 1)
    following = Array.new(total_following) { |i| instance_double(User, id: i + 20) }
    
    allow(user).to receive(:following).and_return(following)
    allow(user).to receive(:total_following).and_return(total_following)
    
    user
  end

  # Helper to create mocked user with completed sleep records
  def user_with_completed_sleep_records(record_count = 3)
    user = instance_double(User, id: 1)
    sleep_records = Array.new(record_count) do |i|
      bedtime = (i + 1).days.ago.change(hour: 22, min: 0)
      wake_time = bedtime + 8.hours
      
      instance_double(SleepRecord,
        id: i + 1,
        user: user,
        bedtime: bedtime,
        wake_time: wake_time,
        duration_minutes: 480,
        created_at: bedtime,
        completed?: true
      )
    end
    
    allow(user).to receive(:sleep_records).and_return(sleep_records)
    allow(user).to receive(:completed_sleep_records).and_return(sleep_records)
    
    user
  end
end

RSpec.configure do |config|
  config.include ModelHelpers, type: :model
end

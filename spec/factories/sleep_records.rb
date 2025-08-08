FactoryBot.define do
  factory :sleep_record do
    user
    bedtime { 8.hours.ago }
    wake_time { 1.hour.ago }
    duration_minutes { 420 } # 7 hours
    score { 4 }
    notes { "Good sleep" }
    status { :completed }

    trait :incomplete do
      wake_time { nil }
      duration_minutes { nil }
      score { nil }
      notes { nil }
      status { :incomplete }
    end

    trait :cancelled do
      wake_time { nil }
      duration_minutes { nil }
      score { nil }
      notes { "Changed my mind" }
      status { :cancelled }
    end

    trait :completed do
      bedtime { 8.hours.ago }
      wake_time { bedtime + 8.hours }
      duration_minutes { 480 }
      score { 4 }
      notes { "Great night's sleep" }
      status { :completed }
    end

    trait :short_sleep do
      bedtime { 4.hours.ago }
      wake_time { bedtime + 4.hours }
      duration_minutes { 240 }
      score { 2 }
      notes { "Too short" }
    end

    trait :long_sleep do
      bedtime { 10.hours.ago }
      wake_time { bedtime + 10.hours }
      duration_minutes { 600 }
      score { 5 }
      notes { "Perfect long sleep" }
    end

    trait :excellent_sleep do
      score { 5 }
      notes { "Amazing sleep!" }
    end

    trait :poor_sleep do
      score { 1 }
      notes { "Terrible night, kept waking up" }
    end
  end
end

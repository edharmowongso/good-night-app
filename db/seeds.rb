# Include TimeHelper for Jakarta timezone
class SeedHelper
  include TimeHelper
  extend TimeHelper
end

puts "🌙 Setting up Good Night App data..."

users = [
  { name: "Eka PD", username: "eka_pd" },
  { name: "Arie Kriting", username: "arie_kriting" },
  { name: "Charlie Brown", username: "charlie_b" },
  { name: "Samuel L Jackson", username: "samuel_s" },
  { name: "Jackie Chan", username: "jackie_c" }
]

puts "\n👥 Creating demo users..."
users.each do |user_attrs|
  user = User.find_or_create_by(username: user_attrs[:username]) do |u|
    u.name = user_attrs[:name]
    u.user_status = :active
  end
  puts "✅ Created user: #{user.name} (@#{user.username}) (ID: #{user.id})"
end

# Create some sample sleep records
puts "\n💤 Creating sample sleep records..."
User.all.each_with_index do |user, user_index|
  # Create records for the past week
  7.times do |i|
    bedtime = SeedHelper.get_current_time_without_str('Asia/Jakarta') - (i + 1).days + (21 + rand(3)).hours + rand(60).minutes
    
    # Vary the sleep records - some completed, some incomplete, some cancelled
    status = case i
    when 0 # Most recent - might be incomplete (currently sleeping)
      user_index.even? ? :incomplete : :completed
    when 1 # Yesterday - might be cancelled
      user_index == 0 ? :cancelled : :completed
    else
      :completed
    end
    
    if status == :incomplete
      # Currently sleeping - no wake time yet
      SleepRecord.create!(
        user: user,
        bedtime: bedtime,
        status: status
      )
    elsif status == :cancelled
      # Cancelled sleep - went to bed but got back up
      SleepRecord.create!(
        user: user,
        bedtime: bedtime,
        status: status,
        notes: ["Changed my mind", "Couldn't sleep", "Forgot something important"].sample
      )
    else
      # Completed sleep with full details
      wake_time = bedtime + (6 + rand(4)).hours
      score = (1..5).to_a.sample
      notes = case score
      when 1 then ["Terrible night", "Kept waking up", "Very restless"].sample
      when 2 then ["Poor sleep", "Woke up tired", "Not refreshing"].sample
      when 3 then ["Okay sleep", "Average night", "Could be better"].sample
      when 4 then ["Good sleep", "Refreshing night", "Feel well rested"].sample
      when 5 then ["Amazing sleep!", "Perfect night", "Feel fantastic"].sample
      end
      
      SleepRecord.create!(
        user: user,
        bedtime: bedtime,
        wake_time: wake_time,
        duration_minutes: ((wake_time - bedtime) / 1.minute).round,
        score: score,
        notes: notes,
        status: status
      )
    end
  end
  puts "  ✅ Created 7 sleep records for #{user.name}"
end

# Create some follow relationships
puts "\n👥 Creating follow relationships..."
eka = User.find_by(username: "eka_pd")
arie = User.find_by(username: "arie_kriting")
charlie = User.find_by(username: "charlie_b")
samuel = User.find_by(username: "samuel_s")

eka&.follow(arie)
eka&.follow(charlie)
arie&.follow(eka)
arie&.follow(samuel)
charlie&.follow(eka)
puts "  ✅ Created follow relationships"

puts "\n✅ Sample data created successfully!"
puts "\n🎯 API Ready!"
puts "   📋 List users: http://localhost:3000/api/v1/users"
puts "\n💡 Test with these user IDs:"
User.all.each { |u| puts "   #{u.name} (@#{u.username}): #{u.id} (Header: X-User-ID: #{u.id})" }

puts "\n📊 Sample data summary:"
puts "  👥 Users: #{User.count} (all active)"
puts "  💤 Sleep records: #{SleepRecord.count}"
puts "  ✅ Completed: #{SleepRecord.completed.count}"
puts "  ⏳ Incomplete: #{SleepRecord.incomplete.count}"
puts "  ❌ Cancelled: #{SleepRecord.cancelled.count}"
puts "  👥 Follow relationships: #{Follow.count}"

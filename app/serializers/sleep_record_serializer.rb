class SleepRecordSerializer
  include JSONAPI::Serializer
  
  attributes :id, :bedtime, :wake_time, :duration_minutes, :score, :notes, :status, :created_at
  
  belongs_to :user
  
  attribute :user_id do |record|
    record.user.id
  end
  
  attribute :duration_hours do |record|
    record.duration_hours
  end
  
  attribute :quality_text do |record|
    record.quality_text
  end
  
  attribute :user_name do |record|
    record.user.name
  end
  
  attribute :user_username do |record|
    record.user.username
  end

  attribute :created_at do |record|
    record.created_at.strftime(DATETIME_FORMAT)
  end
end

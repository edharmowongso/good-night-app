class UserSerializer
  include JSONAPI::Serializer
  
  attributes :id, :name, :username, :user_status, :created_at
  
  attribute :created_at do |record|
    record.created_at.strftime(DATETIME_FORMAT)
  end
  
  attribute :total_followers do |record|
    record.followers.count
  end
  
  attribute :total_following do |record|
    record.following.count
  end
end

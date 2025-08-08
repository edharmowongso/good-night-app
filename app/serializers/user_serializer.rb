class UserSerializer
  include JSONAPI::Serializer
  
  attributes :id, :name, :username, :user_status, :created_at
  
  attribute :created_at do |record|
    record.created_at.strftime(DATETIME_FORMAT)
  end
end

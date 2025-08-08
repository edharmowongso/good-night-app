module Serializable
  extend ActiveSupport::Concern

  private

  def serialize_collection(objects, serializer)
    serializer.new(objects).serializable_hash[:data].map { |item| item[:attributes] }
  end

  def serialize_object(object, serializer)
    serializer.new(object).serializable_hash[:data][:attributes]
  end
end

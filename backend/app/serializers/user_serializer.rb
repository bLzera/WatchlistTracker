class UserSerializer
  include JSONAPI::Serializer

  attributes :id, :name, :email, :confirmed_at, :created_at
end

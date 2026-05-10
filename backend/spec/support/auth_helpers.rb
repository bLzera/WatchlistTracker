module AuthHelpers
  def auth_headers_for(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" }
  end

  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end
end

require "rails_helper"

RSpec.describe "POST /api/v1/auth/signup", type: :request do
  let(:valid_params) do
    {
      user: {
        name: "Maria Silva",
        email: "maria@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }
  end

  context "com dados válidos" do
    it "retorna 201 e mensagem de confirmação" do
      post "/api/v1/auth/signup", params: valid_params, as: :json

      expect(response).to have_http_status(:created)
      expect(json_response[:message]).to include("Verifique seu e-mail")
      expect(json_response[:user][:email]).to eq("maria@example.com")
    end

    it "cria o usuário no banco" do
      expect {
        post "/api/v1/auth/signup", params: valid_params, as: :json
      }.to change(User, :count).by(1)
    end

    it "cria usuário não confirmado" do
      post "/api/v1/auth/signup", params: valid_params, as: :json

      expect(User.last.confirmed_at).to be_nil
    end
  end

  context "com e-mail já cadastrado" do
    before { create(:user, email: "maria@example.com") }

    it "retorna 422 com mensagem de erro" do
      post "/api/v1/auth/signup", params: valid_params, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response[:errors]).to be_present
    end
  end

  context "sem nome" do
    it "retorna 422" do
      post "/api/v1/auth/signup",
           params: valid_params.deep_merge(user: { name: "" }),
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response[:errors]).to include(match(/Name/i))
    end
  end

  context "com senha muito curta" do
    it "retorna 422" do
      post "/api/v1/auth/signup",
           params: valid_params.deep_merge(user: { password: "123", password_confirmation: "123" }),
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  context "com confirmação de senha divergente" do
    it "retorna 422" do
      post "/api/v1/auth/signup",
           params: valid_params.deep_merge(user: { password_confirmation: "outra_senha" }),
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end

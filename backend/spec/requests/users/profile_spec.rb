require "rails_helper"

RSpec.describe "Users Profile", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers_for(user) }

  describe "GET /api/v1/users/me" do
    context "autenticado" do
      it "retorna 200 com os dados do usuário" do
        get "/api/v1/users/me", headers: headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(json_response[:email]).to eq(user.email)
        expect(json_response[:name]).to eq(user.name)
      end

      it "não expõe o encrypted_password" do
        get "/api/v1/users/me", headers: headers, as: :json

        expect(json_response.keys).not_to include(:encrypted_password)
      end
    end

    context "sem token" do
      it "retorna 401" do
        get "/api/v1/users/me", as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /api/v1/users/me" do
    context "autenticado com dados válidos" do
      it "atualiza o nome e retorna 200" do
        patch "/api/v1/users/me",
              params: { user: { name: "Novo Nome" } },
              headers: headers,
              as: :json

        expect(response).to have_http_status(:ok)
        expect(json_response[:name]).to eq("Novo Nome")
        expect(user.reload.name).to eq("Novo Nome")
      end
    end

    context "com e-mail já em uso por outro usuário" do
      let(:outro_user) { create(:user) }

      it "retorna 422" do
        patch "/api/v1/users/me",
              params: { user: { email: outro_user.email } },
              headers: headers,
              as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to be_present
      end
    end

    context "sem token" do
      it "retorna 401" do
        patch "/api/v1/users/me", params: { user: { name: "Teste" } }, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

require "rails_helper"

RSpec.describe "Auth Sessions", type: :request do
  let(:password) { "password123" }
  let(:user) { create(:user, password: password) }
  let(:sign_in_params) { { user: { email: user.email, password: password } } }

  describe "POST /api/v1/auth/sign_in" do
    context "com credenciais válidas e conta confirmada" do
      it "retorna 200 e o token JWT no header Authorization" do
        post "/api/v1/auth/sign_in", params: sign_in_params, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.headers["Authorization"]).to match(/\ABearer .+/)
      end

      it "retorna dados do usuário no corpo" do
        post "/api/v1/auth/sign_in", params: sign_in_params, as: :json

        expect(response).to have_http_status(:ok)
        expect(json_response[:email]).to eq(user.email)
        expect(json_response[:name]).to eq(user.name)
      end
    end

    context "com conta não confirmada" do
      let(:user) { create(:user, :unconfirmed, password: password) }

      it "retorna 401" do
        post "/api/v1/auth/sign_in", params: sign_in_params, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "com senha incorreta" do
      it "retorna 401" do
        post "/api/v1/auth/sign_in",
             params: { user: { email: user.email, password: "errada" } },
             as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "com conta bloqueada" do
      let(:user) { create(:user, :locked, password: password) }

      it "retorna 401" do
        post "/api/v1/auth/sign_in", params: sign_in_params, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/auth/sign_out" do
    context "com token válido" do
      it "retorna 200 e mensagem de logout" do
        post "/api/v1/auth/sign_in", params: sign_in_params, as: :json
        token = response.headers["Authorization"]

        delete "/api/v1/auth/sign_out",
               headers: { "Authorization" => token },
               as: :json

        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to include("Logout")
      end

      it "invalida o token na denylist" do
        post "/api/v1/auth/sign_in", params: sign_in_params, as: :json
        token = response.headers["Authorization"]

        delete "/api/v1/auth/sign_out",
               headers: { "Authorization" => token },
               as: :json

        # Token revogado — não pode mais acessar rotas protegidas
        get "/api/v1/users/me",
            headers: { "Authorization" => token },
            as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "sem token" do
      it "retorna 401" do
        delete "/api/v1/auth/sign_out", as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

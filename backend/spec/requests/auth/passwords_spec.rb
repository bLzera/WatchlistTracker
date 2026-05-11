require "rails_helper"

RSpec.describe "Auth Passwords", type: :request do
  let(:user) { create(:user) }

  describe "POST /api/v1/auth/password" do
    context "com e-mail válido cadastrado" do
      it "retorna 200 com mensagem genérica" do
        post "/api/v1/auth/password",
             params: { user: { email: user.email } },
             as: :json

        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to be_present
      end
    end

    context "com e-mail que não existe" do
      it "retorna 200 (não revela se o e-mail existe)" do
        post "/api/v1/auth/password",
             params: { user: { email: "naocadastrado@example.com" } },
             as: :json

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "PUT /api/v1/auth/password" do
    context "com token válido e nova senha" do
      it "retorna 200 e altera a senha" do
        token = user.send_reset_password_instructions

        put "/api/v1/auth/password",
            params: {
              user: {
                reset_password_token: token,
                password: "novasenha123",
                password_confirmation: "novasenha123"
              }
            },
            as: :json

        expect(response).to have_http_status(:ok)
        expect(user.reload.valid_password?("novasenha123")).to be true
      end
    end

    context "com token inválido" do
      it "retorna 422" do
        put "/api/v1/auth/password",
            params: {
              user: {
                reset_password_token: "token_invalido",
                password: "novasenha123",
                password_confirmation: "novasenha123"
              }
            },
            as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "com senhas divergentes" do
      it "retorna 422" do
        token = user.send_reset_password_instructions

        put "/api/v1/auth/password",
            params: {
              user: {
                reset_password_token: token,
                password: "novasenha123",
                password_confirmation: "diferente"
              }
            },
            as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end

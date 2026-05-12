require "rails_helper"

RSpec.describe "Auth Confirmations", type: :request do
  describe "POST /api/v1/auth/confirmation" do
    context "com e-mail de usuário não confirmado" do
      let(:user) { create(:user, :unconfirmed) }

      it "retorna 200 e reenvia o e-mail de confirmação" do
        post "/api/v1/auth/confirmation",
             params: { user: { email: user.email } },
             as: :json

        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to be_present
      end
    end
  end

  describe "GET /api/v1/auth/confirmation" do
    context "com token válido" do
      let(:user) { create(:user, :unconfirmed) }

      it "confirma o e-mail e retorna 200" do
        # Gera raw + digest diretamente para ter controle total sobre o token
        raw, enc = Devise.token_generator.generate(User, :confirmation_token)
        user.update_columns(confirmation_token: enc, confirmation_sent_at: 1.minute.ago)

        get "/api/v1/auth/confirmation",
            params: { confirmation_token: raw }

        expect(response).to have_http_status(:ok)
        expect(user.reload.confirmed?).to be true
      end
    end

    context "com token inválido" do
      it "retorna 422" do
        get "/api/v1/auth/confirmation",
            params: { confirmation_token: "token_invalido_xyz" }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "quando User#confirm retorna false" do
      let(:user) { create(:user, :unconfirmed) }

      it "retorna 422 com as mensagens de erro" do
        raw, enc = Devise.token_generator.generate(User, :confirmation_token)
        user.update_columns(confirmation_token: enc, confirmation_sent_at: 1.minute.ago)

        allow(User).to receive(:find_by).and_call_original
        allow(User).to receive(:find_by).with(confirmation_token: enc).and_return(user)
        allow(user).to receive(:confirm).and_return(false)
        allow(user).to receive_message_chain(:errors, :full_messages).and_return(["Falha ao confirmar"])

        get "/api/v1/auth/confirmation",
            params: { confirmation_token: raw }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include("Falha ao confirmar")
      end
    end
  end
end

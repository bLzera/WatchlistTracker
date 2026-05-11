module Api
  module V1
    class ConfirmationsController < ApplicationController
      skip_before_action :authenticate_user!

      # POST /api/v1/auth/confirmation — reenviar confirmação (RF-001)
      def create
        User.send_confirmation_instructions(email: params.dig(:user, :email).to_s)
        # Sempre 200 — não revela se o e-mail existe
        render json: { message: "E-mail de confirmação reenviado." }, status: :ok
      end

      # GET /api/v1/auth/confirmation?confirmation_token=... — confirmar token do link
      def show
        token_digest = Devise.token_generator.digest(User, :confirmation_token, params[:confirmation_token].to_s)
        user = User.find_by(confirmation_token: token_digest)

        if user.nil?
          render json: { errors: ["Token de confirmação inválido ou expirado."] },
                 status: :unprocessable_entity
          return
        end

        if user.confirm
          render json: { message: "E-mail confirmado com sucesso. Você já pode fazer login." },
                 status: :ok
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end
end

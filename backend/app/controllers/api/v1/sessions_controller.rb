module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      # sign_in não requer autenticação prévia; sign_out SIM (para revogar o token)
      skip_before_action :authenticate_user!, only: [:create]

      private

      def respond_with(resource, _opts = {})
        render json: UserSerializer.new(resource).serializable_hash[:data][:attributes],
               status: :ok
      end

      # Devise 5.x chama respond_to_on_destroy mesmo sem token (verify_signed_out_user)
      def respond_to_on_destroy(*_args)
        if request.headers["Authorization"].present?
          render json: { message: "Logout realizado com sucesso." }, status: :ok
        else
          render json: { error: "Não autenticado" }, status: :unauthorized
        end
      end
    end
  end
end

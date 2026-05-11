module Api
  module V1
    class PasswordsController < Devise::PasswordsController
      respond_to :json
      skip_before_action :authenticate_user!

      def create
        self.resource = resource_class.send_reset_password_instructions(resource_params)

        # Sempre retorna 200 — não revela se o e-mail existe (RF-003)
        render json: { message: "Se o e-mail existir, você receberá as instruções em breve." },
               status: :ok
      end

      def update
        self.resource = resource_class.reset_password_by_token(resource_params)

        if resource.errors.empty?
          render json: { message: "Senha alterada com sucesso." }, status: :ok
        else
          render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def resource_params
        params.require(:user).permit(:email, :password, :password_confirmation, :reset_password_token)
      end
    end
  end
end

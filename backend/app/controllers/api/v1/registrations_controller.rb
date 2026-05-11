module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json
      skip_before_action :authenticate_user!

      def create
        build_resource(sign_up_params)

        if resource.save
          render json: {
            message: "Conta criada. Verifique seu e-mail para confirmar o cadastro.",
            user: { email: resource.email, name: resource.name }
          }, status: :created
        else
          render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def sign_up_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end

      def respond_with(resource, _opts = {})
        # sobrescrito — resposta tratada em #create
      end
    end
  end
end

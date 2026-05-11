module Api
  module V1
    class UsersController < ApplicationController
      # GET /api/v1/users/me — RF-004
      def me
        render json: UserSerializer.new(current_user).serializable_hash[:data][:attributes],
               status: :ok
      end

      # PATCH /api/v1/users/me — RF-004
      def update_me
        if current_user.update(user_params)
          render json: UserSerializer.new(current_user).serializable_hash[:data][:attributes],
                 status: :ok
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :email)
      end
    end
  end
end

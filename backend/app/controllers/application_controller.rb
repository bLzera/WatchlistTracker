class ApplicationController < ActionController::API
  include Pundit::Authorization

  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError,   with: :render_forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def render_forbidden
    render json: { error: "Acesso negado" }, status: :forbidden
  end

  def render_not_found
    render json: { error: "Não encontrado" }, status: :not_found
  end
end

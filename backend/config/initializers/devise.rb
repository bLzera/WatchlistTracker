Devise.setup do |config|
  config.mailer_sender = ENV.fetch("MAILER_FROM", "noreply@watchlist.local")

  require "devise/orm/active_record"

  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  # API-only: sem redirecionamentos HTML
  config.navigational_formats = []
  config.sign_out_via = :delete

  # Senha mínima de 8 caracteres (RF-001)
  config.password_length = 8..128

  # Confirmação de e-mail (RF-001)
  config.confirm_within = 24.hours
  config.reconfirmable = true

  # Recuperação de senha (RF-003)
  config.reset_password_within = 1.hour

  # Bloqueio após falhas (RF-002)
  config.lock_strategy = :failed_attempts
  config.unlock_strategy = :email
  config.maximum_attempts = 5
  config.unlock_in = 1.hour

  # JWT (devise-jwt)
  config.jwt do |jwt|
    jwt.secret = ENV.fetch("DEVISE_JWT_SECRET_KEY") { Rails.application.credentials.secret_key_base }
    jwt.dispatch_requests = [["POST", %r{^/api/v1/auth/sign_in$}]]
    jwt.revocation_requests = [["DELETE", %r{^/api/v1/auth/sign_out$}]]
    jwt.expiration_time = 24.hours.to_i
  end
end

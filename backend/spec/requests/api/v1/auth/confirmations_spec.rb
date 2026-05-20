# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Auth · Confirmations', type: :request do
  path '/api/v1/auth/confirmation' do
    post 'Reenviar e-mail de confirmação' do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: { email: { type: :string, format: :email } },
            required: ['email']
          }
        },
        required: ['user']
      }

      response '200', 'e-mail reenviado (resposta genérica por segurança)' do
        let(:user) { create(:user, :unconfirmed) }
        let(:payload) { { user: { email: user.email } } }

        run_test!
      end
    end

    get 'Confirmar e-mail via token do link' do
      tags 'Auth'
      description 'Endpoint chamado pelo link enviado no e-mail de confirmação.'
      produces 'application/json'

      parameter name: :confirmation_token, in: :query, schema: { type: :string }, required: true

      response '200', 'e-mail confirmado' do
        let(:user) { create(:user, :unconfirmed) }
        let(:confirmation_token) do
          raw, enc = Devise.token_generator.generate(User, :confirmation_token)
          user.update_columns(confirmation_token: enc, confirmation_sent_at: 1.minute.ago)
          raw
        end

        run_test!
      end

      response '422', 'token inválido ou expirado' do
        schema '$ref' => '#/components/schemas/Error'
        let(:confirmation_token) { 'token_invalido_xyz' }

        run_test!
      end
    end
  end
end

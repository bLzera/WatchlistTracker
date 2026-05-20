# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Auth · Passwords', type: :request do
  path '/api/v1/auth/password' do
    post 'Solicitar e-mail de recuperação de senha' do
      tags 'Auth'
      description <<~DESC
        Envia um e-mail com link de redefinição. Retorna sempre 200 — não
        revela se o e-mail está ou não cadastrado (proteção contra enumeração).
      DESC
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

      response '200', 'instruções enviadas (ou silenciosamente ignorado)' do
        let(:user) { create(:user) }
        let(:payload) { { user: { email: user.email } } }

        run_test!
      end
    end

    put 'Redefinir a senha com o token recebido por e-mail' do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              reset_password_token: { type: :string },
              password: { type: :string, minLength: 6 },
              password_confirmation: { type: :string }
            },
            required: %w[reset_password_token password password_confirmation]
          }
        },
        required: ['user']
      }

      response '200', 'senha redefinida' do
        let(:user) { create(:user) }
        let(:payload) do
          token = user.send_reset_password_instructions
          { user: { reset_password_token: token,
                    password: 'novasenha123',
                    password_confirmation: 'novasenha123' } }
        end

        run_test!
      end

      response '422', 'token inválido ou senhas divergentes' do
        schema '$ref' => '#/components/schemas/Error'

        let(:payload) do
          { user: { reset_password_token: 'token_invalido',
                    password: 'novasenha123',
                    password_confirmation: 'novasenha123' } }
        end

        run_test!
      end
    end
  end
end

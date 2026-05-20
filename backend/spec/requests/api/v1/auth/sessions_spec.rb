# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Auth · Sessions', type: :request do
  path '/api/v1/auth/sign_in' do
    post 'Login do usuário' do
      tags 'Auth'
      description 'Autentica com email e senha. Retorna o JWT no header `Authorization`.'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email, example: 'user@example.com' },
              password: { type: :string, example: 'password123' }
            },
            required: %w[email password]
          }
        },
        required: ['user']
      }

      response '200', 'login bem-sucedido' do
        schema '$ref' => '#/components/schemas/User'
        header 'Authorization', schema: { type: :string }, description: 'JWT no formato `Bearer <token>`'

        let(:existing_user) { create(:user, password: 'password123') }
        let(:credentials) { { user: { email: existing_user.email, password: 'password123' } } }

        run_test!
      end

      response '401', 'credenciais inválidas' do
        schema '$ref' => '#/components/schemas/Error'

        let(:existing_user) { create(:user, password: 'password123') }
        let(:credentials) { { user: { email: existing_user.email, password: 'errada' } } }

        run_test!
      end

      response '401', 'conta não confirmada' do
        schema '$ref' => '#/components/schemas/Error'

        let(:existing_user) { create(:user, :unconfirmed, password: 'password123') }
        let(:credentials) { { user: { email: existing_user.email, password: 'password123' } } }

        run_test!
      end
    end
  end

  path '/api/v1/auth/sign_out' do
    delete 'Logout do usuário' do
      tags 'Auth'
      description 'Revoga o JWT atual (adiciona à denylist). O token deixa de ser aceito.'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '200', 'logout bem-sucedido' do
        let(:user) { create(:user, password: 'password123') }
        let(:Authorization) { auth_headers_for(user)['Authorization'] }

        run_test!
      end

      response '401', 'sem token' do
        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end

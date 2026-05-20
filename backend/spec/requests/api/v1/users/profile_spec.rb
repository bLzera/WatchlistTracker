# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Users · Profile', type: :request do
  path '/api/v1/users/me' do
    get 'Dados do usuário autenticado' do
      tags 'Users'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '200', 'perfil retornado' do
        schema '$ref' => '#/components/schemas/User'

        let(:user) { create(:user) }
        let(:Authorization) { auth_headers_for(user)['Authorization'] }

        run_test!
      end

      response '401', 'sem token' do
        let(:Authorization) { nil }

        run_test!
      end
    end

    patch 'Atualiza o perfil do usuário autenticado' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Novo Nome' },
              email: { type: :string, format: :email }
            }
          }
        },
        required: ['user']
      }

      response '200', 'perfil atualizado' do
        schema '$ref' => '#/components/schemas/User'

        let(:user) { create(:user) }
        let(:Authorization) { auth_headers_for(user)['Authorization'] }
        let(:payload) { { user: { name: 'Novo Nome' } } }

        run_test!
      end

      response '422', 'dados inválidos (ex: e-mail já em uso)' do
        schema '$ref' => '#/components/schemas/Error'

        let(:user) { create(:user) }
        let(:other_user) { create(:user) }
        let(:Authorization) { auth_headers_for(user)['Authorization'] }
        let(:payload) { { user: { email: other_user.email } } }

        run_test!
      end

      response '401', 'sem token' do
        let(:Authorization) { nil }
        let(:payload) { { user: { name: 'Teste' } } }

        run_test!
      end
    end
  end
end

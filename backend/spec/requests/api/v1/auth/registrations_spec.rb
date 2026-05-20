# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Auth · Registrations', type: :request do
  path '/api/v1/auth/signup' do
    post 'Cadastro de novo usuário' do
      tags 'Auth'
      description <<~DESC
        Cria um usuário novo. O usuário recebe um e-mail de confirmação e
        precisa confirmar antes de conseguir fazer login.
      DESC
      consumes 'application/json'
      produces 'application/json'

      parameter name: :signup, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Maria Silva' },
              email: { type: :string, format: :email, example: 'maria@example.com' },
              password: { type: :string, minLength: 6, example: 'password123' },
              password_confirmation: { type: :string, example: 'password123' }
            },
            required: %w[name email password password_confirmation]
          }
        },
        required: ['user']
      }

      response '201', 'usuário criado, e-mail de confirmação enviado' do
        schema type: :object,
               properties: {
                 message: { type: :string },
                 user: {
                   type: :object,
                   properties: {
                     email: { type: :string, format: :email },
                     name: { type: :string }
                   }
                 }
               }

        let(:signup) do
          { user: { name: 'Maria Silva', email: 'maria@example.com',
                    password: 'password123', password_confirmation: 'password123' } }
        end

        run_test!
      end

      response '422', 'dados inválidos (e-mail duplicado, senha curta, etc.)' do
        schema '$ref' => '#/components/schemas/Error'

        before { create(:user, email: 'maria@example.com') }

        let(:signup) do
          { user: { name: 'Maria Silva', email: 'maria@example.com',
                    password: 'password123', password_confirmation: 'password123' } }
        end

        run_test!
      end
    end
  end
end

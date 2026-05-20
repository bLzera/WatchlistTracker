# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'WatchlistTracker API',
        version: 'v1',
        description: <<~DESC
          API REST do WatchlistTracker — app colaborativo para casais gerenciarem listas
          de filmes e séries, com resumos de episódio gerados por IA.

          Autenticação via JWT no header `Authorization: Bearer <token>`.
          O token é retornado no header `Authorization` da resposta do login.
        DESC
      },
      paths: {},
      servers: [
        { url: 'http://localhost:3000', description: 'Desenvolvimento local' },
        { url: 'https://staging.example.com', description: 'Staging' },
        { url: 'https://app.example.com', description: 'Produção' }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          }
        },
        schemas: {
          User: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              email: { type: :string, format: :email, example: 'user@example.com' },
              name: { type: :string, example: 'Maria Silva' },
              confirmed_at: { type: :string, format: 'date-time', nullable: true }
            },
            required: %w[id email]
          },
          Error: {
            type: :object,
            properties: {
              error: { type: :string, example: 'Mensagem de erro' },
              details: {
                type: :object,
                additionalProperties: { type: :array, items: { type: :string } },
                example: { email: ['já está em uso'] }
              }
            }
          }
        }
      },
      tags: [
        { name: 'Auth', description: 'Cadastro, login, recuperação de senha e confirmação de e-mail' },
        { name: 'Users', description: 'Perfil do usuário autenticado' }
      ]
    }
  }

  config.openapi_format = :yaml
end

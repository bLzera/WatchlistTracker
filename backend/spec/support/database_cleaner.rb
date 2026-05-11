require "database_cleaner/active_record"

# Permite URL de serviço Docker (postgres://postgres@postgres:5432/...) no CI e dev
DatabaseCleaner.allow_remote_database_url = true

RSpec.configure do |config|
  config.before(:suite) do
    FactoryBot.lint
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do |example|
    # Request specs usam truncation: evita problemas de isolamento com conexões Rack
    if example.metadata[:type] == :request || example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

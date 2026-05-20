# Pula SimpleCov quando o objetivo do run não é executar código de produção
# (ex: `rake rswag:specs:swaggerize` roda RSpec em --dry-run e zera a cobertura).
unless ENV["SKIP_COVERAGE"] || ARGV.include?("--dry-run")
  require "simplecov"
  SimpleCov.start "rails" do
    minimum_coverage 80
    add_filter "/spec/"
    add_filter "/config/"
    add_filter "/vendor/"
    add_group "Controllers", "app/controllers"
    add_group "Models",      "app/models"
    add_group "Services",    "app/services"
    add_group "Jobs",        "app/jobs"
    add_group "Channels",    "app/channels"
    add_group "Serializers", "app/serializers"
  end
end

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
abort("Rails is in prod — aborting") if Rails.env.production?
require "rspec/rails"

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [ Rails.root.join("spec/fixtures") ]
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
  config.include AuthHelpers, type: :request

  # DatabaseCleaner e FactoryBot.lint configurados em spec/support/database_cleaner.rb
  # Shoulda::Matchers configurado abaixo
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

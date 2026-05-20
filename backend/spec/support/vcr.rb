require "vcr"
require "webmock/rspec"

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.default_cassette_options = { record: :new_episodes }

  # Ocultar chaves de API nos cassetes gravados.
  # TVMaze e MediaWiki não usam chave — não há nada a filtrar para esses hosts.
  config.filter_sensitive_data("<OMDB_API_KEY>")       { ENV["OMDB_API_KEY"] }
  config.filter_sensitive_data("<ANTHROPIC_API_KEY>")  { ENV["ANTHROPIC_API_KEY"] }
end

# Bloquear chamadas HTTP reais no CI — toda chamada externa deve usar VCR
WebMock.disable_net_connect!(allow_localhost: true)

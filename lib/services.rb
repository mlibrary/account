require "canister"
require "semantic_logger"

Services = Canister.new
S = Services

S.register(:log_stream) do
  $stdout.sync = true
  $stdout
end

S.register(:logger) do
  SemanticLogger["account"]
end

S.register(:slack_url) do
  ENV["SLACK_URL"] || "https://hooks.slack.com/services/WHATEVERELSE"
end

S.register(:version) do
  ENV["APP_VERSION"] || "APP_VERSION"
end

SemanticLogger.add_appender(io: S.log_stream, level: :info) unless ENV["APP_ENV"] == "test"

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

SemanticLogger.add_appender(io: S.log_stream, level: :info) unless ENV["APP_ENV"] == "test"

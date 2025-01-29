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

S.register(:log_level) do
  ENV["DEBUG"] ? :debug : :info
end

S.register(:app_env) do
  ENV["APP_ENV"] || "development"
end

class ProductionFormatter < SemanticLogger::Formatters::Json
  # Leave out the pid
  def pid
  end

  # Leave out the timestamp
  def time
  end

  # Leave out environment
  def environment
  end

  # Leave out application (This would be Semantic Logger, which isn't helpful)
  def application
  end
end

case S.app_env
when "production"
  SemanticLogger.add_appender(io: S.log_stream, level: S.log_level, formatter: ProductionFormatter.new)
when "development"
  SemanticLogger.add_appender(io: S.log_stream, level: S.log_level, formatter: :color)
end

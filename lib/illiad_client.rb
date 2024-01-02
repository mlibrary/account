require "httparty"

class ILLiadClient
  include HTTParty
  base_uri "#{ENV.fetch("ILLIAD_API_HOST")}/ILLiadWebPlatform"

  def initialize
    self.class.headers "ApiKey" => ENV.fetch("ILLIAD_API_KEY")
    self.class.headers "Accept" => "application/json"
  end

  def get(url, query = {})
    self.class.get(url, query: query)
  end
end

class Publisher
  include HTTParty
  base_uri "#{ENV.fetch("PATRON_ACCOUNT_BASE_URL")}/updater"
  def publish(params)
    escaped_params = Authenticator.params_with_signature(params: params)
    self.class.post(escaped_params.to_s)
  end
end

# Monkey patch to use system level certificate store
# https://github.com/nahi/httpclient/issues/445
require "httpclient"

class HTTPClient
  alias_method :original_initialize, :initialize

  def initialize(...)
    original_initialize(...)
    # Force use of the default system CA certs (instead of the 6 year old bundled ones)
    @session_manager&.ssl_config&.set_default_paths
  end
end

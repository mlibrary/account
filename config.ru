require "./account"
require "yabeda/prometheus"
require "prometheus/middleware/collector"

Yabeda.configure!

use Rack::Deflater
use Prometheus::Middleware::Collector

run Sinatra::Application

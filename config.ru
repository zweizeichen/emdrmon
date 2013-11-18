#!/usr/bin/env ruby

$: << File.expand_path(File.dirname(__FILE__))

require 'fnordmetric_app'

options = {}
options[:server] = "thin"
options[:host]   = "0.0.0.0"
options[:port]   = "4242"

websocket = FnordMetric::WebSocket.new
webapp = FnordMetric::App.new(options)

dispatch  = Rack::Builder.app do
  use Rack::CommonLogger

  map "/stream" do
    run websocket
  end

  map "/" do
    run webapp
  end

end

Rack::Server.start(
  :app => dispatch,
  :server => options[:server],
  :Host => options[:host],
  :Port => options[:port]
) && FnordMetric.log("listening on http://#{options[:host]}:#{options[:port]}")

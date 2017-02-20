#! /usr/bin/env ruby
#  encoding: UTF-8
#   grahpite_tcp.rb
#
# DESCRIPTION:
#   TCP stats emitter for graphite
#
#   Author / Maintainer: Eric Lakich (github: ericlakich)
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: socket
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'

class Graphite < Sensu::Handler

  # override filters from Sensu::Handler. not appropriate for metric handlers
  def filter; end

  def handle
    graphite_server = settings['graphite']['server']
    graphite_port = settings['graphite']['port']

    metrics = @event['check']['output']

    begin
      timeout(3) do
        sock = TCPSocket.new(graphite_server, graphite_port)
        sock.puts metrics
        sock.close
      end
    rescue Timeout::Error
      puts "graphite -- timed out while sending metrics"
    rescue => error
      puts "graphite -- failed to send metrics : #{error}"
    end
  end

end

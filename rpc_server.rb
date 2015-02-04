#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'
require_relative 'fibonacci_server'

conn = Bunny.new(automatically_recover: false)
conn.start

ch = conn.create_channel

begin
  server = FibonacciServer.new(ch)
  puts " [x] Awaiting RPC requests"
  server.start('rpc_queue')
rescue Interrupt => _
  ch.close
  conn.close

  exit(0)
end
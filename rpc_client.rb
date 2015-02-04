#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'
require_relative 'fibonacci_client'

conn = Bunny.new(automatically_recover: false)
conn.start

ch = conn.create_channel

client = FibonacciClient.new(ch, 'rpc_queue')

puts " [x] Requesting fib(30)"

response = client.call(30)

puts " [.] Got #{response}"

ch.close
conn.close
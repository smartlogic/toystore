# require 'perftools'
require 'pp'
require 'logger'
require 'benchmark'
require 'rubygems'

$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'toystore'
require 'adapter/memory'

Toy.logger = ::Logger.new(STDOUT).tap { |log| log.level = ::Logger::INFO }

class User
  include Toy::Store
  identity_map_off
  store(:memory, {})
end

times = 10_000
user = User.new
id = user.id
attrs = user.persisted_attributes

client_result = Benchmark.realtime {
  times.times { User.store.write(id, attrs) }
}
store_result = Benchmark.realtime {
  times.times { User.create }
}

puts 'Client', client_result
puts 'Toystore', store_result
puts 'Ratio', store_result / client_result

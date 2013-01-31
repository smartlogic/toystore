# require 'perftools'
require 'pp'
require 'benchmark'
require 'rubygems'

$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'toystore'
require 'adapter/memory'

class User
  include Toy::Store
end

times = 10_000
user = User.new
id = user.id
attrs = user.persisted_attributes

adapter_result = Benchmark.realtime {
  times.times { User.adapter.write(id, attrs) }
}
toystore_result = Benchmark.realtime {
  times.times { User.create }
}

puts 'Client', adapter_result
puts 'Toystore', toystore_result
puts 'Ratio', toystore_result / adapter_result

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
  attribute :name, String
end

user  = User.create(:name => 'John')
id    = user.id
times = 10_000

client_result = Benchmark.realtime {
  times.times { User.store.decode(User.store.client[User.store.key_for(id)]) }
}

store_result = Benchmark.realtime {
  times.times { User.get(id) }
}

puts 'Client', client_result
puts 'Toystore', store_result
puts 'Ratio', store_result / client_result

# PerfTools::CpuProfiler.start('prof_client') do
#   times.times{ User.store.decode(User.store.client[User.store.key_for(id)]) }
# end

# PerfTools::CpuProfiler.start('prof_reads') do
#   times.times{ User.get(id) }
# end

# system('pprof.rb --gif --ignore=Collection#find_one prof_reads > prof_reads.gif')
# system('open prof_reads.gif')
# require 'perftools'
require 'pp'
require 'benchmark'
require 'rubygems'

$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'toystore'
require 'adapter/memory'

class User
  include Toy::Store
  attribute :name, String
end

user  = User.create(:name => 'John')
id    = user.id
times = 10_000

adapter_result = Benchmark.realtime {
  times.times { User.adapter.decode(User.adapter.client[User.adapter.key_for(id)]) }
}

toystore_result = Benchmark.realtime {
  times.times { User.get(id) }
}

puts 'Client', adapter_result
puts 'Toystore', toystore_result
puts 'Ratio', toystore_result / adapter_result

# PerfTools::CpuProfiler.start('prof_client') do
#   times.times{ User.adapter.decode(User.adapter.client[User.adapter.key_for(id)]) }
# end

# PerfTools::CpuProfiler.start('prof_reads') do
#   times.times{ User.get(id) }
# end

# system('pprof.rb --gif --ignore=Collection#find_one prof_reads > prof_reads.gif')
# system('open prof_reads.gif')

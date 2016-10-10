$:.unshift(File.expand_path('../../lib', __FILE__))

require 'pathname'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')

require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

require 'toy'

Dir[root_path.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |c|
  c.include(Support::Constants)
  c.include(Support::Objects)
  c.include(IdentityMapMatcher)
  c.include(InstrumenterHelpers)

  c.fail_fast = true
  c.filter_run focused: true
  c.alias_example_to :fit, focused: true
  c.alias_example_to :xit, pending: true
  c.run_all_when_everything_filtered = true

  c.before(:each) do
    Toy::IdentityMap.enabled = false
    Toy.key_factory = nil
    clear_instrumenter
  end
end

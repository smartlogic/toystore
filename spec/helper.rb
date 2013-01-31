$:.unshift(File.expand_path('../../lib', __FILE__))

require 'pathname'
require 'logger'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
log_path  = root_path.join('log')
log_path.mkpath

require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

require 'toy'
require 'support/constants'
require 'support/objects'
require 'support/identity_map_matcher'
require 'support/name_and_number_key_factory'
require 'support/shared_active_model_lint'

Toy.logger = Logger.new(log_path.join('test.log'))

RSpec.configure do |c|
  c.include(Support::Constants)
  c.include(Support::Objects)
  c.include(IdentityMapMatcher)

  c.fail_fast = true
  c.filter_run :focused => true
  c.alias_example_to :fit, :focused => true
  c.alias_example_to :xit, :pending => true
  c.run_all_when_everything_filtered = true

  c.before(:each) do
    Toy::IdentityMap.enabled = false
    Toy.key_factory = nil
  end
end

require 'pp'
require 'pathname'
require 'rubygems'
require 'adapter/riak'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)
require 'toystore'

class GameList
  include Toy::Store
  adapter :riak, Riak::Client.new['adapter_example']

  attribute :source, Hash
end

list = GameList.create(:source => {'foo' => 'bar'})

pp list
pp GameList.read(list.id)

list.destroy

pp GameList.read(list.id)

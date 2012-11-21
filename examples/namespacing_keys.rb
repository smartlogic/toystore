require 'pp'
require 'rubygems'
require 'pathname'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)

require 'toystore'

class NamespacedUUIDKeyFactory < Toy::Identity::AbstractKeyFactory
  def key_type
    String
  end

  def next_key(object)
    [object.class.name, SimpleUUID::UUID.new.to_guid].join(':')
  end
end

class User
  include Toy::Store
  key NamespacedUUIDKeyFactory.new
end

puts User.new.id # User:some_uuid

# or use namespaces for all classes

Toy.key_factory = NamespacedUUIDKeyFactory.new

class Game
  include Toy::Store
end

puts Game.new.id # Game:some_uuid

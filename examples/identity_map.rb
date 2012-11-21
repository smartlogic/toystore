require 'pp'
require 'pathname'
require 'rubygems'
require 'adapter/memory'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)
require 'toystore'

# More Reading...
# http://martinfowler.com/eaaCatalog/identityMap.html
# http://en.wikipedia.org/wiki/Identity_map

# Identity map is turned off by default for Toystore so let's turn it on
Toy::IdentityMap.enabled = true
puts 'Identity map enabled'

class User
  include Toy::Store

  attribute :name, String
end

user = User.create(:name => 'John')
# User is added to identity map
# ToyStore SET #<User:0x10220b4c8> :memory "08a1c54c-3393-11e0-8b37-89da41d2f675"
#   {"name"=>"John"}
# ToyStore IMS User "08a1c54c-3393-11e0-8b37-89da41d2f675"

puts "With identity map - User.read(user.id).equal?(user): #{User.read(user.id).equal?(user)}"
# User is retrieved from identity map instead of querying
# ToyStore IMG User "08a1c54c-3393-11e0-8b37-89da41d2f675"

Toy::IdentityMap.without do
  puts "Without identity map - User.read(user.id).equal?(user): #{User.read(user.id).equal?(user)}"
  # User is queried from database
  # ToyStore GET User :memory "08a1c54c-3393-11e0-8b37-89da41d2f675"
  #   {"name"=>"John"}
end

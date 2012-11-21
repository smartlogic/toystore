require 'pp'
require 'pathname'
require 'rubygems'
require 'adapter/memory'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)
require 'toystore'

##################################################################
# An example of all the goodies you get by including Toy::Object #
##################################################################

class Person
  include Toy::Object

  attribute :name, String
  attribute :age,  Integer
end

# Pretty class inspecting
pp Person

john  = Person.new(:name => 'John',  :age => 30)
steve = Person.new(:name => 'Steve', :age => 31)

# Pretty inspecting
pp john

# Attribute dirty tracking
john.name = 'NEW NAME!'
pp john.changes       # {"name"=>["John", "NEW NAME!"], "age"=>[nil, 30]}
pp john.name_changed? # true

# Equality goodies
pp john.eql?(john)  # true
pp john.eql?(steve) # false
pp john == john     # true
pp john == steve    # false

# Cloning
pp john.clone

# Inheritance
class AwesomePerson < Person
end

pp Person.attributes.keys.sort          # ["age", "name"]
pp AwesomePerson.attributes.keys.sort   # ["age", "name", "type"]

# Serialization
puts john.to_json
puts john.to_xml

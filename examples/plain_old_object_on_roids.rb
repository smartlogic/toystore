require 'pp'
require 'pathname'
require 'rubygems'
require 'adapter/memory'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)
require 'toystore'

#################################################################
# An example of all the goodies you get by including Toy::Store #
# Note that you also get all of the goodies in Toy::Object.     #
#################################################################

class Person
  include Toy::Store

  attribute :name, String
  attribute :age,  Integer, :default => 0
end

# Persistence
john = Person.create(:name => 'John', :age => 30)
pp john
pp john.persisted?

# Mass Assignment Security
Person.attribute :role, String, :default => 'guest'
Person.attr_accessible :name, :age

person = Person.new(:name => 'Hacker', :age => 13, :role => 'admin')
pp person.role # "guest"

# Querying
pp Person.read(john.id)
pp Person.read_multiple([john.id])
pp Person.read('NOT HERE') # nil

begin
  Person.read!('NOT HERE')
rescue Toy::NotFound
  puts "Could not find person with id of 'NOT HERE'"
end

# Reloading
pp john.reload

# Callbacks
class Person
  before_create :add_fifty_to_age

  def add_fifty_to_age
    self.age += 50
  end
end

pp Person.create(:age => 10).age # 60

# Validations
class Person
  validates_presence_of :name
end

person = Person.new
pp person.valid?        # false
pp person.errors[:name] # ["can't be blank"]

# Lists (array key stored as attribute)
class Skill
  include Toy::Store

  attribute :name, String
  attribute :truth, Boolean
end

class Person
  list :skills, Skill
end

john.skills = [Skill.create(:name => 'Programming', :truth => true)]
john.skills << Skill.create(:name => 'Mechanic', :truth => false)

pp john.skills.map(&:id) == john.skill_ids # true

# References (think foreign keyish)
class Person
  reference :mom, Person
end

mom = Person.create(:name => 'Mum')
john.mom = mom
john.save
pp john.reload.mom_id == mom.id # true

# Identity Map
Toy::IdentityMap.use do
  frank = Person.create(:name => 'Frank')

  pp Person.read(frank.id).equal?(frank)                # true
  pp Person.read(frank.id).object_id == frank.object_id # true
end

# Or you can turn it on globally
Toy::IdentityMap.enabled = true
frank = Person.create(:name => 'Frank')

pp Person.read(frank.id).equal?(frank)                # true
pp Person.read(frank.id).object_id == frank.object_id # true

# All persistence runs through an adapter.
# All of the above examples used the default in-memory adapter.
# Looks something like this:
Person.adapter :memory, {}

puts "Adapter: #{Person.adapter.inspect}"

# You can make a new adapter to your awesome new/old data store
Adapter.define(:append_only_array) do
  def read(key)
    if (record = client.reverse.detect { |row| row[0] == key })
      record
    end
  end

  def write(key, value)
    client << [key, value]
    value
  end

  def delete(key)
    client.delete_if { |row| row[0] == key }
  end

  def clear
    client.clear
  end
end

client = []
Person.adapter :append_only_array, client

pp "Client: #{Person.adapter.client.equal?(client)}"

person = Person.create(:name => 'Phil', :age => 55)
person.age = 56
person.save

pp client

pp Person.read(person.id) # Phil with age 56

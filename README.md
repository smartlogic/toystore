# Toystore [![Build Status](https://secure.travis-ci.org/jnunemaker/toystore.png)](http://travis-ci.org/jnunemaker/toystore)

An object mapper for any [adapter](https://github.com/jnunemaker/adapter) that can read, write, delete, and clear data.

## Examples

The project comes with two main includes that you can use -- Toy::Object and Toy::Store.

**Toy::Object** comes with all the goods you need for plain old ruby objects -- attributes, dirty attribute tracking, equality, inheritance, serialization, cloning, logging and pretty inspecting.

**Toy::Store** includes Toy::Object and adds persistence through adapters, mass assignment, querying, callbacks, validations and a few simple associations (lists and references).

### Toy::Object

First, join me in a whirlwind tour of Toy::Object.

```ruby
class Person
  include Toy::Object

  attribute :name, String
  attribute :age,  Integer
end

# Pretty class inspecting
puts Person.inspect

john = Person.new(:name => 'John', :age => 30)
steve = Person.new(:name => 'Steve', :age => 31)

# Pretty inspecting
puts john.inspect

# Attribute dirty tracking
john.name = 'NEW NAME!'
puts john.changes.inspect       # {"name"=>["John", "NEW NAME!"], "age"=>[nil, 30]}
puts john.name_changed?.inspect # true

# Equality goodies
puts john.eql?(john)  # true
puts john.eql?(steve) # false
puts john == john     # true
puts john == steve    # false

# Cloning
puts john.clone.inspect

# Inheritance
class AwesomePerson < Person
end

puts Person.attributes.keys.sort.inspect          # ["age", "id", "name"]
puts AwesomePerson.attributes.keys.sort.inspect   # ["age", "id", "name", "type"]

# Serialization
puts john.to_json
puts john.to_xml
```

Ok, that was definitely awesome. Please continue on your personal journey to a blown mind (very similar to a beautiful mind).

### Toy::Store

Toy::Store is a unique bird that builds on top of Toy::Object. Below is a quick sample of what it can do.

```ruby
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
pp Person.get(john.id)
pp Person.get_multiple(john.id)
pp Person.get('NOT HERE') # nil
pp Person.get_or_new('NOT HERE') # new person with id of 'NOT HERE'

begin
  Person.get!('NOT HERE')
rescue Toy::NotFound
  puts "Could not find person with id of 'NOT HERE'"
end

# Reloading
pp john.reload

# Callbacks
class Person
  def add_fifty_to_age
    self.age += 50
  end
end

class Person
  before_create :add_fifty_to_age
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

  pp Person.get(frank.id).equal?(frank)                # true
  pp Person.get(frank.id).object_id == frank.object_id # true
end

# Or you can turn it on globally
Toy::IdentityMap.enabled = true
frank = Person.create(:name => 'Frank')

pp Person.get(frank.id).equal?(frank)                # true
pp Person.get(frank.id).object_id == frank.object_id # true

# All persistence runs through an adapter.
# All of the above examples used the default in-memory adapter.
# Looks something like this:
Person.adapter :memory, {}

puts "Adapter: #{Person.adapter.inspect}"

# You can make a new adapter to your awesome new/old data store
# Always use #key_for, #encode, and #decode. Feel free to override
# them if you like, but always use them. Default encode/decode is
# most likely marshaling, but you can use anything.
Adapter.define(:append_only_array) do
  def read(key)
    if (record = client.reverse.detect { |row| row[0] == key_for(key) })
      decode(record)
    end
  end

  def write(key, value)
    key   = key_for(key)
    value = encode(value)
    client << [key, value]
    value
  end

  def delete(key)
    key = key_for(key)
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

pp Person.get(person.id) # Phil with age 56
```

If that doesn't excite you, nothing will. At this point, you are probably wishing for more.

Luckily, there is an entire directory full of [examples](https://github.com/jnunemaker/toystore/tree/master/examples) and I created a few power user guides, which I will kindly link next.

## ToyStore Power User Guides

* [Wiki Home](https://github.com/jnunemaker/toystore/wiki)
* [Identity](https://github.com/jnunemaker/toystore/wiki/Identity)
* [Types](https://github.com/jnunemaker/toystore/wiki/Types)
* [Exceptions](https://github.com/jnunemaker/toystore/wiki/Exceptions)

## Changelog

As of 0.8.3, I started keeping a [changelog](https://github.com/jnunemaker/toystore/blob/master/Changelog.md). All significant updates will be summarized there.

## Compatibility

* Rails 3.0.*, 3.1.*, 3.2.*, Sinatra, etc. No Rails 2 (because it uses Active Model).
* Ruby 1.8.7, REE, and 1.9.3

## Mailing List

https://groups.google.com/forum/#!forum/toystoreadapter

## Contributing

* Fork the project.
* Make your feature addition or bug fix in a topic branch.
* Add tests for it. This is important so we don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or changelog. (if you want to have your own version, that is fine, but bump version in a commit by itself so we can ignore when we pull)
* Send a pull request.

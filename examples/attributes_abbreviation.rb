require 'pp'
require 'pathname'
require 'rubygems'
require 'adapter/memory'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)
require 'toystore'

class User
  include Toy::Store

  attribute :email, String
  attribute :my_really_long_field_name, String, :abbr => :my
end

user = User.create({
  :email => 'nunemaker@gmail.com',
  :my_really_long_field_name => 'something',
})

pp User.adapter.client[user.id]
# Abbreviated attributes are stored in the database as the abbreviation for when you want to conserve space. The abbreviation and the full attribute name work exactly the same in Ruby, the only difference is how they get persisted.
# {"my"=>"something", "email"=>"nunemaker@gmail.com"}

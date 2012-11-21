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
  attribute :crypted_password, String

  attribute :password, String, :virtual => true
  attribute :password_confirmation, String, :virtual => true

  before_validation :encrypt_password

private
  def encrypt_password
    self.crypted_password = encrypt(password)
  end

  def encrypt(password)
    password # do something magical here
  end
end

user = User.create({
  :email => 'nunemaker@gmail.com',
  :password => 'testing',
  :password_confirmation => 'testing',
})

pp User.adapter.client[user.id]
# Virtual attributes are never persisted. In the data store, only email and crypted_password are stored.
# {"crypted_password"=>"testing", "email"=>"nunemaker@gmail.com"}

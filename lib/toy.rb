require 'set'
require 'pathname'
require 'forwardable'
require 'digest/sha1'

root_path = Pathname(__FILE__).dirname.join('..').expand_path

require 'adapter/memory'
require 'simple_uuid'
require 'active_model'
require 'active_support/json'
require 'active_support/core_ext'

extensions_path = root_path.join('lib', 'toy', 'extensions')
Dir[extensions_path + '**/*.rb'].each { |file| require(file) }

module Toy
  extend self

  # Resets all tracking of things in memory. Useful for running
  # before each request in development mode with Rails and such.
  def reset
    IdentityMap.clear
    plugins.clear
    models.clear
  end

  # Clears all the adapters for all the models. Useful in specs/tests/etc.
  # Do not use in production, harty harr harr.
  #
  # Note: that if your models are auto-loaded like in Rails, you will need
  # to make sure they are loaded in order to clear them or ToyStore will
  # not be aware of their existence.
  def clear
    models.each do |model|
      model.adapter.clear
    end
    IdentityMap.clear
  end

  def logger
    @logger
  end

  def logger?
    @logger.present?
  end

  def logger=(logger)
    @logger = logger
  end

  def key_factory=(key_factory)
    @key_factory = key_factory
  end

  def key_factory
    @key_factory ||= Toy::Identity::UUIDKeyFactory.new
  end

  module Middleware
    autoload 'IdentityMap', 'toy/middleware/identity_map'
  end

  autoload 'Attribute',               'toy/attribute'
  autoload 'Attribute',               'toy/attribute'
  autoload 'Attributes',              'toy/attributes'
  autoload 'Caching',                 'toy/caching'
  autoload 'Callbacks',               'toy/callbacks'
  autoload 'Dirty',                   'toy/dirty'
  autoload 'DirtyStore',              'toy/dirty_store'
  autoload 'Cloneable',               'toy/cloneable'
  autoload 'Equality',                'toy/equality'
  autoload 'Inspect',                 'toy/inspect'
  autoload 'Inheritance',             'toy/inheritance'
  autoload 'Logger',                  'toy/logger'
  autoload 'MassAssignmentSecurity',  'toy/mass_assignment_security'
  autoload 'Persistence',             'toy/persistence'
  autoload 'Querying',                'toy/querying'
  autoload 'Reloadable',              'toy/reloadable'
  autoload 'Serialization',           'toy/serialization'
  autoload 'AssociationSerialization','toy/association_serialization'
  autoload 'Timestamps',              'toy/timestamps'
  autoload 'Validations',             'toy/validations'

  autoload 'List',                    'toy/list'
  autoload 'Lists',                   'toy/lists'
  autoload 'Reference',               'toy/reference'
  autoload 'References',              'toy/references'
  autoload 'Identity',                'toy/identity'

  module Identity
    autoload 'AbstractKeyFactory',    'toy/identity/abstract_key_factory'
    autoload 'UUIDKeyFactory',        'toy/identity/uuid_key_factory'
    autoload 'NativeUUIDKeyFactory',  'toy/identity/native_uuid_key_factory'
  end
end

require 'toy/identity_map'
require 'toy/exceptions'
require 'toy/plugins'
require 'toy/object'
require 'toy/store'

Toy::IdentityMap.enabled = false

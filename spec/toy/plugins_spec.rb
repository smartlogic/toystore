require 'helper'

describe Toy::Plugins do
  uses_constants('User', 'Game')

  it "keeps track of class that include toy store" do
    Toy.models.should == [User, Game]
  end

  describe ".plugin" do
    before do
      @mod = Module.new {
        extend ActiveSupport::Concern

        def bar
          'bar'
        end
      }

      class_methods_module = Module.new do
        def foo
          'foo'
        end
      end

      @mod.const_set :ClassMethods, class_methods_module

      Toy.plugin(@mod)
    end

    it "includes module in all models" do
      [User, Game].each do |model|
        model.foo.should     == 'foo'
        model.new.bar.should == 'bar'
      end
    end

    it "adds plugin to plugins" do
      Toy.plugins.should == [@mod]
    end

    it "adds plugins to classes declared after plugin was called" do
      klass = ToyStore()
      klass.foo.should     == 'foo'
      klass.new.bar.should == 'bar'
    end
  end
end

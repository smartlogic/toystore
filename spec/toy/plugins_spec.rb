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

        module ClassMethods
          def foo
            'foo'
          end
        end

        def bar
          'bar'
        end
      }

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
      klass = Class.new { include Toy::Store }
      klass.foo.should     == 'foo'
      klass.new.bar.should == 'bar'
    end
  end
end

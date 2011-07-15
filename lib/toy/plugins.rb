module Toy
  def models
    Toy::Store.direct_descendants
  end

  def plugins
    Toy::Store.plugins
  end

  def plugin(mod)
    Toy::Store.plugin(mod)
  end

  module Plugins
    include ActiveSupport::DescendantsTracker

    def plugins
      @plugins ||= []
    end

    def plugin(mod)
      include(mod)
      direct_descendants.each {|model| model.send(:include, mod) }
      plugins << mod
    end

    def included(base=nil, &block)
      direct_descendants << base if base
      super
    end
  end
end

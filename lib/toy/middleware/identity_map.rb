require 'rack/body_proxy'

module Toy
  module Middleware
    class IdentityMap
      def initialize(app)
        @app = app
      end

      def call(env)
        Toy::IdentityMap.clear
        enabled = Toy::IdentityMap.enabled
        Toy::IdentityMap.enabled = true

        response = @app.call(env)
        response[2] = Rack::BodyProxy.new(response[2]) {
          Toy::IdentityMap.enabled = enabled
          Toy::IdentityMap.clear
        }
        response
      end
    end
  end
end

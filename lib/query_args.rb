require 'sinatra/base'

module Sinatra
  module OpenApiQueryArgs

    def self.registered(app)
      app.set :max_records, 40
      app.set :default_limit, 20
      app.set :default_order, 'id desc'

      app.helpers do
        def fetch_limit
          @limit = settings.default_limit
          limit_from_params = params.delete('limit') 
          if limit_from_params
            @limit = limit_from_params.to_i < settings.max_records ? limit_from_params : settings.max_records
          end 
        end #def

        def fetch_order
          order_from_params = params.delete('order')
          @order = order_from_params ? order_from_params : settings.default_order
        end

        def fetch_offset(limit)
          @offset = 0
          page_from_params = params.delete('page').to_i
          if page_from_params
            @offset = limit.to_i * page_from_params
          end #if
        end

      end #helpers

      app.before do
        fetch_limit
        fetch_order
        fetch_offset(@limit)
      end

    end

  end

  register OpenApiQueryArgs
end

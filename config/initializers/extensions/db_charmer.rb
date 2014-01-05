module DbCharmer
  module ActiveRecord
    module MultiDbProxy
      # Simple proxy class that switches connections and then proxies all the calls
      # This class is used to implement chained on_db calls
      class OnDbProxy < ActiveSupport::BasicObject

        def initialize(proxy_target, slave)
          @proxy_target = proxy_target
          @slave = slave
        end

        def connection_name(connection_config_or_name)
          if connection_config_or_name.respond_to?(:connection_name) && connection_config_or_name.connection_name != nil
            connection_config_or_name.connection_name.to_sym
          else
            connection_config_or_name
          end
        end

        def method_should_use_master?(method)
          write_methods = [:create, :create, :update, :update!, :destroy, :delete]
          write_methods.include? method
        end

        def db_to_use(meth)
          default = connection_name(@slave)
          if method_should_use_master?(meth) && @proxy_target.respond_to?(:master_version_of_connection)
            connection_name_sym = @proxy_target.master_version_of_connection(default)
          else
            connection_name_sym = default
          end
          connection_name_sym
        end

        # Determines whether this query is chained off of a db_charmer "on_db" call.
        def db_has_been_specified(proxy_target, method)
          if proxy_target.respond_to? :db_charmer_connection_level
            level = proxy_target.db_charmer_connection_level
            return false if (method =~ /connection$/ && level <= 1)
          end

          return true
        end

        # Beware, modifications made to this method will be very brittle
        # Even simply calling a method on the res variable will cause the db to be changed
        def method_missing(meth, *args, &block)
          # Switch connection and proxy the method call
          default = db_to_use(meth)

          @proxy_target.on_db(default) do |proxy_target|
            res = proxy_target.__send__(meth, *args, &block)

            # These exact conditions will determine if this sharded model hasn't had "on_db" chained
            # If that's the case, raise an error, since this could lead to a query being ran on the wrong db

            if @proxy_target.respond_to?(:prevent_chaining_without_on_db?) &&
              @proxy_target.prevent_chaining_without_on_db? &&
              !db_has_been_specified(proxy_target, meth)

              raise "Tried to access #{proxy_target.name} without having selected a shard. Maybe you chained a method call off of an object that has an association to #{proxy_target.name}"
            end

            # If result is a scope/association, return a new proxy for it, otherwise return the result itself
            (res.proxy?) ? OnDbProxy.new(res, default) : res
          end
        end

      end

    end
  end
end

require 'active_support/concern'

module WriteableModelConcerns
  extend ActiveSupport::Concern

  %w[create create! save save! update update! destroy delete destroy_all delete_all].each do |method|
    define_method method do |*args|
      writable_connection = master_version_of_connection(connection.current_database)
      self.class.on_db(writable_connection) do
        super(*args)
      end
    end
  end

  def master_version_of_connection(connection_name)
    connection_name = connection_name.to_s

    return connection_name if connection_name[-3..-1] == '_rw'

    if connection_name.index('_ro')
      connection_name.sub! '_ro', '_rw'
    else
      connection_name << '_rw'
    end

    connection_name.to_sym
  end

end

ActiveRecord::Base.send(:include, WriteableModelConcerns)








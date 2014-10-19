class Loader

  attr_accessor :data_type, :updates, :source

  def initialize(data_type, updates, source)
    @data_type = data_type
    @updates = updates
    @source = source
  end

end
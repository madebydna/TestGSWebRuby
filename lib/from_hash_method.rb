module FromHashMethod
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def from_hash(hash)
      new.tap do |instance|
        hash.each_pair do |k,v|
          begin
            instance.send("#{k}=", v)
          rescue => e
            GSLogger.error(:misc, e, message: "Tried to invoke unknown method #{k} on #{self.name}")
          end
        end
      end
    end
  end
end

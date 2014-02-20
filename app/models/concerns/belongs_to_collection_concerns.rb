module BelongsToCollectionConcerns
  extend ActiveSupport::Concern

  included do
    attr_accessible :collection_id, :collection
  end

  def collection=(collection)
    if collection.blank?
      self.collection_id = nil
    elsif collection && collection.match(/^\d+$/)
      self.collection_id = collection.to_i
    else
      self.collection_id = collection.id
    end
  end

  def collection
    @collection ||= Collection.find(self.collection_id)
  end

end

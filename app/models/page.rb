class Page < ActiveRecord::Base
  attr_accessible :name, :parent

  has_many :category_placements, :order => 'collection_id desc'

  belongs_to :parent, :class_name => 'Page'
  has_many :pages, :foreign_key => 'parent_id'


  # Returns a hash of {position number => Category}
  # If collection(s) are passed in, the hash will only contain entries for categories that match the collections
  def categories_per_position(collections = nil)

    # get the right category placements
    placements = CategoryPlacement.belonging_to_collections(self, collections)

    # build the hash
    placements.inject({}) do |hash, placement|
      hash[placement.position] ||= placement.category
      hash
    end

  end


end

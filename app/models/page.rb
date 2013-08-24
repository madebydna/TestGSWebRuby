class Page < ActiveRecord::Base
  attr_accessible :name, :parent

  has_many :category_placements, :order => 'collection_id desc'

  belongs_to :parent, :class_name => 'Page'
  has_many :pages, :foreign_key => 'parent_id'


  # Returns a hash of {position number => Category}
  # If collection(s) are passed in, the hash will only contain entries for categories that match the collections
  def categories_per_position(collections = nil)
    placements = category_placements

    # get the right category placements
    if collections
      placements = category_placements.belonging_to_collections collections
    end

    # build the hash
    placements.inject({}) do |hash, placement|
      hash[placement.position] ||= placement.category
      hash
    end
  end


end

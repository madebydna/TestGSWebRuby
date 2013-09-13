class Page < ActiveRecord::Base
  attr_accessible :name, :parent
  has_paper_trail

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

      # default the value to an empty Array
      hash[placement.position] ||= []

      # push an item onto the Array
      hash[placement.position] << placement

      hash
    end

  end

  def code_friendly_name
    name.gsub('&',' ').gsub(/\s+/, '_').classify
  end


end

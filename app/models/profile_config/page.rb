class Page < ActiveRecord::Base
  attr_accessible :name, :parent
  has_paper_trail
  db_magic :connection => :profile_config

  include BelongsToCollectionConcerns
  has_many :category_placements, :order => 'collection_id desc'
  belongs_to :parent, :class_name => 'Page'
  has_many :pages, :foreign_key => 'parent_id'

  def self.by_name(name)
    where(name: name).first
  end

  def code_friendly_name
    name.gsub('&',' ').gsub(/\s+/, '_').classify
  end


end

class SchoolRating < ActiveRecord::Base
  octopus_establish_connection(:adapter => "mysql2", :database => "surveys")

  self.table_name='school_rating'

  scope :group_filter, lambda { |show_by_group| where(:who => show_by_group)  unless show_by_group.empty? }
  #scope :recent, order("posted DESC")
  #scope :oldest, order("posted ASC")
  #scope :rating_top, order("quality DESC")
  #scope :rating_bottom, order("quality ASC")

  def self.fetch_reviews(school, group_to_fetch, order_results_by)
    # TODO: restrict reviews to correct statuses
    # .limit(10).offset(30)  for getting next ten in ajax
    SchoolRating.where(school_id: school.id, state: school.state).group_filter(group_to_fetch).order_by(order_results_by)
  end
  def self.order_by(order_selection)
    case order_selection
      when 'oldest'
        order("posted ASC")
      when 'rating_top'
        order("quality DESC, posted DESC")
      when 'rating_bottom'
        order("quality ASC, posted DESC")
      else
        order("posted DESC")
    end
  end
end
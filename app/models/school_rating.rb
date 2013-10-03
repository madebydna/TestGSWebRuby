class SchoolRating < ActiveRecord::Base
  octopus_establish_connection(:adapter => "mysql2", :database => "surveys")

  self.table_name='school_rating'

  #scope :recent, order("posted DESC")
  #scope :oldest, order("posted ASC")
  #scope :rating_top, order("quality DESC")
  #scope :rating_bottom, order("quality ASC")
  scope :review_selection_filter, lambda { |show_by_group| where(:who => show_by_group)  unless show_by_group == 'all' || show_by_group.empty? }
  scope :review_limit_number, lambda { |limit_number| limit(limit_number)  unless limit_number.to_s.empty? }
  scope :review_offset_number, lambda { |offset_start| offset(offset_start)  unless offset_start.to_s.empty? }

  def self.fetch_reviews(school, group_to_fetch, order_results_by, offset_start, quantity_to_return)
    # TODO: restrict reviews to correct statuses
    SchoolRating.where(school_id: school.id, state: school.state)
      .review_selection_filter(group_to_fetch)
      .order_by_selection(order_results_by)
      .review_limit_number(quantity_to_return)
      .review_offset_number(offset_start)
  end

  def self.order_by_selection(order_selection)
    case order_selection
      when 'oldToNew'
        order("posted ASC")
      when 'ratingsHighToLow'
        order("quality DESC, posted DESC")
      when 'ratingsLowToHigh'
        order("quality ASC, posted DESC")
      else
        order("posted DESC")
    end
  end
end
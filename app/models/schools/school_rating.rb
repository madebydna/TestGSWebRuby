class SchoolRating < ActiveRecord::Base
  db_magic :connection => :surveys

  self.table_name='school_rating'

  scope :selection_filter, lambda { |show_by_group| where(:who => show_by_group)  unless show_by_group == 'all' || show_by_group.empty? }
  scope :limit_number, lambda { |limit_number| limit(limit_number)  unless limit_number.to_s.empty? }
  scope :offset_number, lambda { |offset_start| offset(offset_start)  unless offset_start.to_s.empty? }
  scope :published, where(:status => ['a', 'p'])
  scope :quality_decline, where("quality != 'decline'")

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

  def self.fetch_reviews(school, group_to_fetch, order_results_by, offset_start, quantity_to_return)
    SchoolRating.where(school_id: school.id, state: school.state)
      .selection_filter(group_to_fetch)
      .order_by_selection(order_results_by)
      .limit_number(quantity_to_return)
      .offset_number(offset_start)
      .published
      .quality_decline
  end
end
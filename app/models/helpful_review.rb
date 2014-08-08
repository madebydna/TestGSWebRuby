class HelpfulReview < ActiveRecord::Base
  db_magic :connection => :surveys

  scope :in_review_list, ->(reviews){ where( review_id: reviews.map(&:id))}
  scope :in_review_list_id, ->(review_ids){ where( review_id: review_ids )}

  def self.helpful_counts(reviews)
    helpful_count = HelpfulReview.select("review_id, Count(*) as count").in_review_list(reviews).group(:review_id)
    helpful_count.inject({}) { |hash, row| hash[row[:review_id]] = row[:count]; hash }
  end

  def self.helpful_counts_by_id(review_ids)
    helpful_count = HelpfulReview.select("review_id, Count(*) as count").in_review_list_id(review_ids).group(:review_id)
    helpful_count.inject({}) { |hash, row| hash[row[:review_id]] = row[:count]; hash }
  end

end
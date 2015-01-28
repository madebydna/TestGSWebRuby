require 'spec_helper'

describe HelpfulReview do
  after do
    clean_dbs :surveys
  end

  # test hash results for array of review ids passed into method -- helpful_counts_by_id(review_ids) --   three tests: no items, 1 item, many items

  # need to stub out review objects for this.
  # test hash results for array of reviews passed into method  -- helpful_counts(reviews) --   three tests: no items, 1 item, many items

end
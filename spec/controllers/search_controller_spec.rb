require 'spec_helper'

describe SearchController do
  [PaginationConcerns, GoogleMapConcerns, MetaTagsHelper, HubConcerns].each do | mod |
    it "should include #{mod.to_s}" do
      expect(SearchController.ancestors.include?(mod)).to be_truthy
    end
  end
end

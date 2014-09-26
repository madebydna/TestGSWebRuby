require 'spec_helper'
def all_cache_keys
  # TODO Grab this from populate school cache? Need to refactor that file to just be the script runner
  ['ratings','characteristics', 'esp_responses', 'reviews_snapshot']
end

def init_school_with_cache
  let(:school) { FactoryGirl.build(:an_elementary_school) }
  let(:query) { SchoolCacheQuery.new.include_cache_keys(all_cache_keys) }
  let(:query_results) { query.include_schools(school.state, school.id).query }
  let(:school_cache_results) { SchoolCacheResults.new(all_cache_keys, query_results) }
  let(:school_with_cache) { school_cache_results.decorate_schools([school]).first }
end
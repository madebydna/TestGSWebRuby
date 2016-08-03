require 'spec_helper'

describe SchoolProfiles::Hero do
  let(:school_cache_data_reader) { double('school_cache_data_reader') }
  subject(:hero) do
    SchoolProfiles::Hero.new(
      school_cache_data_reader: school_cache_data_reader
    )
  end
  it { is_expected.to respond_to(:gs_rating) }
end

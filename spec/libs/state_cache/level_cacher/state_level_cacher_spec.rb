require 'spec_helper'

describe LevelCaching::StateLevelCacher do

  def create_school(level, type)
    FactoryGirl.create_on_shard(:ca, :school, level_code: level, type: type)
  end

  describe "#build_hash_for_cache" do
    after(:all) { do_clean_models(:ca, School) }
    
    before(:all) do
      @elem_public = create_school('p,e', 'public')
      @elem_private = create_school('e', 'private')
      @pre_private = create_school('p,e,m', 'private')
      @mid_public = create_school('m,h', 'public')
      @mid_charter = create_school('m', 'charter')
      @high_public = create_school('h', 'public')
    end

    let(:cacher) { LevelCaching::StateLevelCacher.new('ca') }
    let(:hash) { cacher.build_hash_for_cache }

    it "should have all level keys" do
      cacher.level_keys.each do |key|
        expect(hash).to have_key(key)
      end
    end

    it "should have correct number of schools" do
      expect(hash['all']).to eq(6)
    end

    it "should have correct number of preschools" do
      expect(hash['preschool']).to eq(2)
    end

    it "should have correct number of elementary schools" do
      expect(hash['elementary']).to eq(3)
    end

    it "should have correct number of middle schools" do
      expect(hash['middle']).to eq(3)
    end

    it "should have correct number of high schools" do
      expect(hash['high']).to eq(2)
    end

    it "should have correct number of private schools" do
      expect(hash['private']).to eq(2)
    end

    it "should have correct number of public schools" do
      expect(hash['public']).to eq(3)
    end

    it "should have correct number of charter schools" do
      expect(hash['charter']).to eq(1)
    end
  end
end
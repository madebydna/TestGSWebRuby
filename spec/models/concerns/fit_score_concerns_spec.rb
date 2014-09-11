require 'spec_helper'

describe FitScoreConcerns do
  before(:all) do
    class FakeModel
      include FitScoreConcerns
    end
  end
  after(:all) { Object.send :remove_const, :FakeModel }
  let(:model) { FakeModel.new }

  describe '#matches_soft_filter?' do
    it "Doesn't match class_offerings=visual_media_arts if model doesn't have arts_visual attribute" do
      expect(model.send('matches_soft_filter?', 'class_offerings', 'visual_media_arts')).to be_falsey
    end

    it "Doesn't match class_offerings=visual_media_arts if arts_visual is 'none'" do
      allow(model).to receive(:arts_visual).and_return(['none'])
      expect(model.send('matches_soft_filter?', 'class_offerings', 'visual_media_arts')).to be_falsey
    end
    it "Doesn't match class_offerings=performance_arts if arts_performing_written is 'none'" do
      allow(model).to receive(:arts_performing_written).and_return(['none'])
      expect(model.send('matches_soft_filter?', 'class_offerings', 'performance_arts')).to be_falsey
    end
    it "Doesn't match class_offerings=music if arts_music is 'none'" do
      allow(model).to receive(:arts_music).and_return(['none'])
      expect(model.send('matches_soft_filter?', 'class_offerings', 'music')).to be_falsey
    end

    it "Does match class_offerings=visual_media_arts when arts_visual=painting" do
      allow(model).to receive(:arts_visual).and_return(['painting'])
      expect(model.send('matches_soft_filter?', 'class_offerings', 'visual_media_arts')).to be_truthy
    end
    it "Does match class_offerings=performance_arts when arts_performing_written=drama" do
      allow(model).to receive(:arts_performing_written).and_return(['drama'])
      expect(model.send('matches_soft_filter?', 'class_offerings', 'performance_arts')).to be_truthy
    end
    it "Does match class_offerings=music when arts_music=band" do
      allow(model).to receive(:arts_music).and_return(['band'])
      expect(model.send('matches_soft_filter?', 'class_offerings', 'music')).to be_truthy
    end

    it "Doesn't match school_focus=arts if academic_focus is 'none'" do
      allow(model).to receive(:academic_focus).and_return(['none'])
      expect(model.send('matches_soft_filter?', 'school_focus', 'arts')).to be_falsey
    end
    ['all_arts', 'visual_arts', 'performing_arts', 'music'].each do |var|
      it "Does match school_focus=arts if academic_focus is '#{var}'" do
        allow(model).to receive(:academic_focus).and_return([var])
        expect(model.send('matches_soft_filter?', 'school_focus', 'arts')).to be_truthy
      end
    end
    it "Doesn't match school_focus=college_focus if instructional_model is 'none'" do
      allow(model).to receive(:instructional_model).and_return(['none'])
      expect(model.send('matches_soft_filter?', 'school_focus', 'college_focus')).to be_falsey
    end
    ['AP_courses', 'ib', 'college_prep'].each do |var|
      it "Does match school_focus=college_focus if instructional_model is '#{var}'" do
        allow(model).to receive(:instructional_model).and_return([var])
        expect(model.send('matches_soft_filter?', 'school_focus', 'college_focus')).to be_truthy
      end
    end
  end
end

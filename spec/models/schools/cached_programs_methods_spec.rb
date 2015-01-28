require 'spec_helper'

describe CachedProgramsMethods do
  before(:all) do
    class FakeModel
      include CachedProgramsMethods
    end
  end
  after(:all) { Object.send :remove_const, :FakeModel }
  let(:model) { FakeModel.new }

  describe '#num_programs' do
    let(:programs_counts_hash_lc) {{
        'academic_focus' => { 'none' => {}},
        'boys_sports' => {
          'baseball' => {},
          'basketball' => {},
          'none' => {}
        },
        'girls_sports' => {
          'none' => {}
        },
        'arts_performing_written' => {
            'none' => {}
        },
        'arts_visual' => {
            'none' => {}
        },
        'arts_media' => {
            'none' => {}
        },
        'arts_music' => {
            'none' => {}
        },
        'student_clubs' => {
            'none' => {}
        },
        'foreign_language' => {
            'none' => {}
        },
    }}
    let(:programs_counts_hash_uc) {{
        'academic_focus' => { 'None' => {}},
        'boys_sports' => {
          'baseball' => {},
          'basketball' => {},
          'None' => {}
        },
        'girls_sports' => {
          'None' => {}
        },
        'arts_performing_written' => {
            'None' => {}
        },
        'arts_visual' => {
            'None' => {}
        },
        'arts_media' => {
            'None' => {}
        },
        'arts_music' => {
            'None' => {}
        },
        'student_clubs' => {
            'None' => {}
        },
        'foreign_language' => {
            'None' => {}
        },
    }}
    it 'does not count none' do
      allow(model).to receive(:programs).and_return programs_counts_hash_lc
      expect(model.send(:sports)).to eq(2)
      expect(model.send(:clubs)).to eq(0)
      expect(model.send(:world_languages)).to eq(0)
      expect(model.send(:arts_and_music)).to eq(0)
      expect(model.send(:num_programs, 'girls_sports')).to eq(0)
      expect(model.send(:num_programs, 'boys_sports')).to eq(2)
      expect(model.send(:num_programs, 'academic_focus')).to eq(0)
    end
    it 'does not count None' do
      allow(model).to receive(:programs).and_return programs_counts_hash_uc
      expect(model.send(:sports)).to eq(2)
      expect(model.send(:clubs)).to eq(0)
      expect(model.send(:world_languages)).to eq(0)
      expect(model.send(:arts_and_music)).to eq(0)
      expect(model.send(:num_programs, 'girls_sports')).to eq(0)
      expect(model.send(:num_programs, 'boys_sports')).to eq(2)
      expect(model.send(:num_programs, 'academic_focus')).to eq(0)
    end
  end
end
require 'spec_helper'

describe HomepageFeatures do
  describe '.initialize' do
    let(:hash) do
      {
        'status' => 'ok',
        'first_feature' => {
          'heading' => 'Explore our new parenting site, GreatKids!',
          'posts' => [
            {
              'id' => 16418
            }
          ]
        }
      }
    end
    subject { HomepageFeatures.new(hash) }
    it { is_expected.to be_present }
    its(:first_feature) { is_expected.to be_present }
    it 'should have heading set on its first feature' do
      expect(subject.first_feature.heading).to be_present
    end
  end
end
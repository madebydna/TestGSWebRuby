require 'spec_helper'

shared_examples_for 'model with active field' do |klass = described_class, factory = klass.name.snakecase |

  describe 'Class' do
    subject { klass }
    it { is_expected.to respond_to(:active) }
  end

  describe '.active' do
    let!(:first_active) { FactoryGirl.create(factory, :active) }
    let!(:first_inactive) { FactoryGirl.create(factory, :inactive) }
    let!(:second_active) { FactoryGirl.create(factory, :active) }
    after do
      clean_models klass
    end
    it "should find only active #{klass.name.pluralize}" do
      expect(klass.active.size).to eq(2)
      expect(klass.active.first.id).to eq(first_active.id)
      expect(klass.active.last.id).to eq(second_active.id)
    end
  end

  describe '#active=' do
    let!(:first) { FactoryGirl.create(factory, :active) }
    let!(:second) { FactoryGirl.create(factory, :inactive) }
    after do
      clean_models klass
    end
    [true, 1].each do |value|
      it "should correctly handle #{value} as true" do
        first.active = value
        first.save
        second.active = value
        second.save
        first.reload
        second.reload
        expect(first).to be_active
        expect(second).to be_active
      end
    end
    [false, 0].each do |value|
      it "should correctly handle #{value} as false" do
        first.active = value
        first.save
        second.active = value
        second.save
        first.reload
        second.reload
        expect(first).to be_inactive
        expect(second).to be_inactive
      end
    end
  end

  describe '#deactivate' do
    let!(:object) { FactoryGirl.create(factory, :active) }
    after do
      clean_models klass
    end
    it 'should set active flag to false' do
      expect { object.deactivate }.to change { object.active? }.from(true).to(false)
    end
  end

  describe '#activate' do
    let!(:object) { FactoryGirl.create(factory, :inactive) }
    after do
      clean_models klass
    end
    it 'should set active flag to true' do
      expect { object.activate }.to change { object.active? }.from(false).to(true)
    end
  end

  describe '#active?' do
    subject { FactoryGirl.create(factory, :active) }
    after do
      clean_models klass
    end
    it { is_expected.to be_active }
    it { is_expected.to_not be_inactive }
  end

  describe '#inactive?' do
    subject { FactoryGirl.create(factory, :inactive) }
    after do
      clean_models klass
    end
    it { is_expected.to be_inactive }
    it { is_expected.to_not be_active }
  end

end
require 'spec_helper'

describe AdvertisingConcerns do

  let(:controller) { FakeController.new }
  before(:all) do
    class FakeController
      include AdvertisingConcerns
    end
  end

  after(:all) { Object.send :remove_const, :FakeController }

  describe '#set_global_ad_targeting_through_gon' do

    ['a','b'].each do |version|
      context "for ab version #{version}" do
        let(:gon) { Struct.new(:advertising_enabled).new(nil) }
        let (:ad_targeting_gon_hash) { {} }
        before do
          allow(controller).to receive(:gon) { gon }
          allow(controller).to receive(:ad_targeting_gon_hash) { ad_targeting_gon_hash }
          allow(controller).to receive(:ab_version) { version }
        end

        shared_example "it sets Responsive_Group key to #{ version == 'a' ? 'Control' : 'Test'} for ab version: #{version}" do
          subject
          result = version == 'a' ?  'Control' : 'Test'
          expect(ad_targeting_gon_hash['Responsive_Group']).to eq(result)
        end

        subject { controller.set_global_ad_targeting_through_gon }

        context 'when advertising enabled' do
          let(:env_global) { {'advertising_env' => 'blah'} }
          before { allow(controller).to receive(:advertising_enabled?).and_return(true) }

          include_example "it sets Responsive_Group key to #{ version == 'a' ? 'Control' : 'Test'} for ab version: #{version}"

          it 'should set values for gon ad_set_targeting hash' do
            stub_const('ENV_GLOBAL', env_global)
            subject
            expect(gon.advertising_enabled).to be_truthy
            expect(ad_targeting_gon_hash['compfilter'].to_i).to be_between(1,4)
            expect(ad_targeting_gon_hash['env']).to eq('blah')
          end
        end

        context 'with advertising not enabled' do
          before {allow(controller).to receive(:advertising_enabled?).and_return(false) }

          include_example "it sets Responsive_Group key to #{ version == 'a' ? 'Control' : 'Test'} for ab version: #{version}"

          it 'should not set ad values for gon hash' do
            subject
            expect(gon.advertising_enabled).to be_falsey
            expect(ad_targeting_gon_hash['compfilter']).to eq(nil)
            expect(ad_targeting_gon_hash['env']).to eq(nil)
          end
        end
      end
    end
  end

  describe '#advertising_enabled?' do
    subject { controller.advertising_enabled? }
    let(:property_config) { double }
    before do
      stub_const('PropertyConfig', property_config)
      stub_const('ENV_GLOBAL', env_global)
    end

    shared_example 'should check if PropertyConfig enables advertising' do
      expect(property_config).to receive(:advertising_enabled?)
      subject
    end

    context 'ENV_GLOBAL advertising enabled variable is nil' do
      let(:env_global) {{}}
      include_example 'should check if PropertyConfig enables advertising'
    end

    context 'ENV_GLOBAL advertising enabled variable is true' do
      let(:env_global) {{'advertising_enabled' => true}}
      include_example 'should check if PropertyConfig enables advertising'
    end

    context 'ENV_GLOBAL advertising enabled variable is false' do
      let(:env_global) {{'advertising_enabled' => false}}

      it 'should not check if PropertyConfig enables advertising' do
        expect(property_config).to_not receive(:advertising_enabled?)
        subject
      end
      it { is_expected.to be_falsey }
    end

  end


  describe AdvertisingConcerns::AdvertisingFormatterHelper do
    describe '.format_ad_setTargeting' do
      subject { AdvertisingConcerns::AdvertisingFormatterHelper }
      context 'when the parameter is an array' do
        it 'should return an array' do
          parameter = ['param1', 'param2']
          value = subject.format_ad_setTargeting(parameter)
          expect(value).to be_an_instance_of Array
        end

        it 'should return an array with elements of length less than or equal to 10' do
          parameter = ['totally_more_than_ten_characters', 'yup_also_more_than_ten_characters']
          value = subject.format_ad_setTargeting(parameter)
          expect(value).to be_an_instance_of Array
          value.each do | val |
            expect(val.length <= 10).to be_truthy
          end
        end
      end

      [:class, 'class', Class, 9910897115115, 9910897115115.0].each do | parameter |
        context "when the parameter is a #{parameter.class}" do

        it 'should return a string' do
          value = subject.format_ad_setTargeting(parameter)
          expect(value).to be_an_instance_of String
        end

        it 'should remove spaces' do
          value = subject.format_ad_setTargeting(parameter)
          expect(value).not_to include ' '
        end

        it 'should truncate it to at most 10 characters' do
          value = subject.format_ad_setTargeting(parameter)
          expect(value.length < 11).to be_truthy
        end
      end
      end
    end

  end


end

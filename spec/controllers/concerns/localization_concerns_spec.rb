require 'spec_helper'

shared_examples_for 'localization' do
  let(:school) {
    FactoryGirl.build(
      :school,
      state: 'ca',
      collections: FactoryGirl.build_list(
        :collection,
        1,
        name: 'a hub name',
        hub_city_mapping: FactoryGirl.build(
          :hub_city_mapping,
          state: 'dc',
          city: 'washington'
        )
      )
    )
  }

  RSpec::Matchers.define :be_a_boolean do
    match do |actual|
      actual.is_a?(TrueClass) || actual.is_a?(FalseClass)
    end
  end

  describe '#set_hub_cookies' do
    before(:each) do
      controller.stub(:write_cookie_value)
    end

    after(:each) do
      controller.view_context.set_hub_cookies
    end

    context 'no school' do
      it 'should not write any cookies' do
        expect(controller).to_not receive(:write_cookie_value)
        controller.instance_variable_set(:@school, nil)
      end
    end

    context 'a school' do
      before(:each) do
        controller.instance_variable_set(:@school, school)
      end

      it 'writes a hubState cookie using the school\'s state ' do
        controller.stub(:write_cookie_value)
        expect(controller).to receive(:write_cookie_value).with(:hubState, 'CA')
      end

      it 'writes a hubCity cookie using the collection nickname' do
        controller.stub(:write_cookie_value)
        school.collection.stub(:nickname).and_return('collection nickname')
        expect(controller).to receive(:write_cookie_value).with(:hubCity, 'collection nickname')
      end

      context 'with a collection' do
        it 'should write some hub specific cookies based on collection/hub configuration' do
          expect(controller).to receive(:write_cookie_value).with(:eduPage, be_a_boolean)
          expect(controller).to receive(:write_cookie_value).with(:choosePage, be_a_boolean)
          expect(controller).to receive(:write_cookie_value).with(:eventsPage, be_a_boolean)
          expect(controller).to receive(:write_cookie_value).with(:enrollPage, be_a_boolean)
          expect(controller).to receive(:write_cookie_value).with(:partnerPage, be_a_boolean)
        end
      end

      context 'without a collection' do
        it 'should not write any hub specific cookies based on collection/hub configuration' do
          school.collections = nil
          expect(controller).to_not receive(:write_cookie_value).with(:eduPage)
          expect(controller).to_not receive(:write_cookie_value).with(:choosePage)
          expect(controller).to_not receive(:write_cookie_value).with(:eventsPage)
          expect(controller).to_not receive(:write_cookie_value).with(:enrollPage)
          expect(controller).to_not receive(:write_cookie_value).with(:partnerPage)
        end
      end
    end
  end

end
require 'spec_helper'

describe RatingSourceConcerns do
  before(:all) do
    class FakeController < ActionController::Base
      include RatingSourceConcerns

      def url_options
        {}
      end
    end
  end

  after(:all) { Object.send :remove_const, :FakeController }

  let(:controller) { FakeController.new }

  describe '#rating_source' do
    subject { controller.rating_source(params) }
    let(:params) { {year: 2017, label: 'This is the label'} }

    before do
      expect(controller).to receive(:rating_static_label).with(:source).and_return('Source')
      expect(controller).to receive(:rating_static_label).with(:calculated_in).and_return('Calculated in')
    end

    it { is_expected.to include('Source') }
    it { is_expected.to include('GreatSchools') }
    it { is_expected.to include('Calculated in 2017') }
    it { is_expected.to include('This is the label') }
    it { is_expected.not_to include('See more') }
    it { is_expected.not_to include('About this rating') }

    context 'with a description' do
      let(:description) { 'This is the description.' }
      before do
        params[:description] = description
        expect(controller).to receive(:rating_db_label).with(description).and_return(description)
      end

      it { is_expected.to include("<p>#{description}</p>") }
    end

    context 'with a methodology' do
      let(:methodology) { 'This is the methodology.' }
      before do
        params[:methodology] = methodology
        expect(controller).to receive(:rating_db_label).with(methodology).and_return(methodology)
      end

      it { is_expected.to include("<p>#{methodology}</p>") }
    end

    context 'with both description and methodology' do
      let(:description) { 'This is the description.' }
      let(:methodology) { 'This is the methodology.' }
      before do
        params[:description] = description
        params[:methodology] = methodology
        expect(controller).to receive(:rating_db_label).with(description).and_return(description)
        expect(controller).to receive(:rating_db_label).with(methodology).and_return(methodology)
      end

      it { is_expected.to include("<p>#{description} #{methodology}</p>") }
    end

    context 'with an anchor' do
      let(:more_anchor) { 'anchor' }

      before do
        params[:more_anchor] = more_anchor
        expect(controller).to receive(:rating_static_label).with(:see_more).and_return('See more')
        expect(controller).to receive(:rating_static_label).with(:about_this_rating).and_return('About this rating')

        allow_any_instance_of(ActionDispatch::Request).to receive(:subdomain).and_return('www')
        default_url_options[:host] = 'greatschools.org'
      end

      it { is_expected.to include('See more') }
      it { is_expected.to include('About this rating') }
      it { is_expected.to include('/gk/ratings/#anchor') }
    end
  end
end
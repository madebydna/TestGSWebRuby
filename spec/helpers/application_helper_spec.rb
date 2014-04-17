require 'spec_helper'

describe ApplicationHelper do
  describe '#category_placement_anchor' do
    let(:category_placement) {
      FactoryGirl.build(:category_placement, id: 1, title: 'A title', category: FactoryGirl.build(:category))
    }

    it 'should use the category placement title if available' do
      expect(helper.category_placement_anchor(category_placement)).to eq 'A_title_1'
    end

    it 'should use the category name if there is no title' do
      category_placement.title = nil
      expect(helper.category_placement_anchor(category_placement)).to eq 'Test_category_1'
    end
  end

  describe '#draw_stars' do
    describe 'should return html with correct on and off class values' do
      it 'should draw both color stars' do
        html = helper.draw_stars(16, 1)
        spans = html.split('</span>')
        expect(spans.first).to match /orange/
        expect(spans.first).to_not match /grey/
        expect(spans.last).to match /grey/
        expect(spans.last).to_not match /orange/
      end

      it 'for 1 star on' do
        html = helper.draw_stars(16, 1)
        spans = html.split('</span>')
        expect(spans.first).to match /i-\d+-star-1/
        expect(spans.last).to match /i-\d+-star-4/
      end

      it 'for 0 stars on' do
        html = helper.draw_stars(16, 0)
        spans = html.split('</span>')
        expect(spans.first).to match /i-\d+-star-0/
        expect(spans.last).to match /i-\d+-star-5/
      end

      it 'for 5 stars on' do
        html = helper.draw_stars(16, 5)
        spans = html.split('</span>')
        expect(spans.first).to match /i-\d+-star-5/
        expect(spans.last).to match /i-\d+-star-0/
      end
    end

    it 'should set the right size' do
      html = helper.draw_stars(16, 1)
      spans = html.split('</span>')
      expect(spans.first).to match /i-16-star-\d+/
      expect(spans.last).to match /i-16-star-\d+/
    end
  end

  describe '#topnav_formatted_title' do
    before(:each) do
      helper.stub(:cookies).and_return(cookies)
      clean_dbs :gs_schooldb, :ca
    end
    let(:hub_params) { { city: 'detroit', state: 'michigan' } }
    let(:school) do
      FactoryGirl.create(:hub_city_mapping, city: 'a name', state: 'CA')
      school = FactoryGirl.create(:school, school_metadatas: [])
      school
    end
    let(:cookies) { {} }

    it 'sets ishubUser all the time' do
      helper.topnav_formatted_title(school, hub_params, cookies)

      expect(helper.cookies[:ishubUser][:value]).to eq('y')
    end

    context 'with a school' do
      it 'sets the nav city and state based on the school' do
        result = helper.topnav_formatted_title(school, hub_params, cookies)
        expect(result).to eq("A Name, CA")
      end

      it 'sets cookies based on school properties' do
        helper.topnav_formatted_title(school, hub_params, cookies)
        expect(helper.cookies[:hubState][:value]).to eq('CA')
        expect(helper.cookies[:hubCity][:value]).to eq('A Name')
      end

      it 'sets page configuration options from the school' do
        helper.topnav_formatted_title(school, hub_params, cookies)
        expect(helper.cookies[:eduPage][:value]).to be_true
        expect(helper.cookies[:choosePage][:value]).to be_true
        expect(helper.cookies[:eventsPage][:value]).to be_true
        expect(helper.cookies[:enrollPage][:value]).to be_true
        expect(helper.cookies[:partnerPage][:value]).to be_true
      end
    end

    context 'with a state page' do
      before(:each) { FactoryGirl.create(:hub_city_mapping, city: nil, state: 'IN') }
      let(:hub_params) { { state: 'indiana' } }
      let(:school) { nil }

      it 'displays state based on the hub params' do
        result = helper.topnav_formatted_title(school, hub_params, cookies)
        expect(result).to eq('Indiana')
      end

      it 'sets cookies for the state based off of hub params' do
        helper.topnav_formatted_title(school, hub_params, cookies)
        expect(helper.cookies[:hubState][:value]).to eq('IN')
      end
    end

    context 'with city pages' do
      before(:each) { FactoryGirl.create(:hub_city_mapping, city: 'detroit', state: 'MI') }
      let(:school) { nil }

      it 'displays city and state based on hub params' do
        result = helper.topnav_formatted_title(school, hub_params, cookies)
        expect(result).to eq('Detroit, MI')
      end
      it 'sets cookies for city and state based off hub params' do
        helper.topnav_formatted_title(school, hub_params, cookies)
        expect(helper.cookies[:hubCity][:value]).to eq('Detroit')
        expect(helper.cookies[:hubState][:value]).to eq('MI')
      end
      it 'sets page configuration cookies from hub params' do
        helper.topnav_formatted_title(school, hub_params, cookies)
        expect(helper.cookies[:eduPage][:value]).to be_true
        expect(helper.cookies[:choosePage][:value]).to be_true
        expect(helper.cookies[:eventsPage][:value]).to be_true
        expect(helper.cookies[:enrollPage][:value]).to be_true
        expect(helper.cookies[:partnerPage][:value]).to be_true
      end
    end

    context 'with non profile pages' do
      let(:hub_params) { nil }
      let(:school) { nil }

      context 'with cookies' do
        it 'reads from the cookies' do
          keys = [:eduPage, :choosePage, :eventsPage, :enrollPage, :partnerPage]
          keys.each { |k| helper.cookies[k] = true }
          helper.topnav_formatted_title(school, hub_params, cookies)

          keys.each do |key|
            expect(helper.cookies[key]).to be_true
          end
        end
      end

      context 'without cookies' do
        it 'returns nil' do
          result = helper.topnav_formatted_title(school, hub_params, cookies)
          expect(result).to be_nil
        end
      end
    end
  end
end

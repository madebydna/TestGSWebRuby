require 'spec_helper'

describe Admin::DataLoadSchedulesController do

  it 'should have the right methods' do
    expect(controller).to respond_to :update
    expect(controller).to respond_to :create
    expect(controller).to respond_to :index
  end

  describe '#update' do
    before do
      request.env['HTTP_REFERER'] = 'www.greatschools.org/blah'
    end
    after do
      expect(response).to redirect_to request.env['HTTP_REFERER']
    end

    it 'should update the data load if one is found' do
      data_load = FactoryGirl.build(:data_load)
      Admin::DataLoadSchedule.stub(:find).and_return(data_load)
      expect(data_load).to receive(:update_attributes).and_return true
      post :update, id: 1
    end

    it 'should handle update failure by setting flash message' do
      data_load = FactoryGirl.build(:data_load)
      Admin::DataLoadSchedule.stub(:find).and_return(data_load)
      expect(data_load).to receive(:update_attributes).and_return false
      expect(controller).to receive(:flash_error)
      post :update, id: 1
    end
  end

  describe '#create' do
    before do
      request.env['HTTP_REFERER'] = 'www.greatschools.org/blah'
    end
    after do
      expect(response).to redirect_to request.env['HTTP_REFERER']
    end

    it 'should create a data load if one is found' do
      data_load = FactoryGirl.build(:data_load)
      Admin::DataLoadSchedule.stub(:find).and_return(data_load)
      expect(data_load).to receive(:update_attributes).and_return true
      post :update, id: 1
    end

    it 'should handle update failure by setting flash message' do
      data_load = FactoryGirl.build(:data_load)
      Admin::DataLoadSchedule.stub(:find).and_return(data_load)
      expect(data_load).to receive(:update_attributes).and_return false
      expect(controller).to receive(:flash_error)
      post :update, id: 1
    end
  end

  describe '#index' do
    let(:data_load) { FactoryGirl.build(:data_load) }
    let(:completed_data_load) { FactoryGirl.build(:completed_data_load) }
    let(:incomplete_data_load) { FactoryGirl.build(:incomplete_data_load) }

    before do
      controller.stub(:filter_and_sort_data_loads).and_return data_loads
    end

    it 'should look for all data loads if not provided a filter' do
      expect(Admin::DataLoadSchedule).to receive(:all)
      get :index
    end

    context 'provided a completed only filter' do
      before do
        expect(Admin::DataLoadSchedule).to receive(:completed).and_return(completed_data_load)
      end

      it 'should look for a completed school if provided a completed filter' do
        expect(Admin::DataLoadSchedule).to_not receive(:completed)
        get :index, filter_by: 'complete'
      end

      it 'should expose reported reviews to the view' do
        get :moderation, filter_by: 'complete'
        expect(assigns[:loads]).to eq data_loads
      end
    end
  end
  #
  # describe '#unprocessed_reviews' do
  #   let(:school) { FactoryGirl.build(:school) }
  #   let(:reviews) { FactoryGirl.build_list(:valid_school_rating, 3) }
  #
  #   it 'should return reviews for specific school if school is set' do
  #     controller.instance_variable_set(:@school, school)
  #     reviews = double('reviews')
  #     expect(reviews).to receive(:order).and_return reviews
  #     expect(reviews).to receive(:page).and_return reviews
  #     expect(reviews).to receive(:per).and_return reviews
  #     school.stub(:school_ratings).and_return reviews
  #     expect(controller.send :unprocessed_reviews).to eq(reviews)
  #   end
  #
  #   it 'should return unpublished and held reviews if no school is set' do
  #     reviews = double('reviews')
  #     expect(reviews).to receive(:order).and_return reviews
  #     expect(reviews).to receive(:page).and_return reviews
  #     expect(reviews).to receive(:per).and_return reviews
  #     expect(SchoolRating).to receive(:where).with(status: %w[u h]).and_return reviews
  #     expect(controller.send :unprocessed_reviews).to eq(reviews)
  #   end
  # end
  #
  # describe '#flagged reviews' do
  #   let(:school) { FactoryGirl.build(:school) }
  #   let(:reviews) { FactoryGirl.build_list(:valid_school_rating, 3) }
  #
  #   it 'should return any previously flagged review for school if school is set' do
  #     controller.instance_variable_set(:@school, school)
  #     reviews = double('reviews')
  #     expect(reviews).to receive(:order).and_return reviews
  #     expect(reviews).to receive(:page).and_return reviews
  #     expect(reviews).to receive(:per).and_return reviews
  #     expect(reviews).to receive(:ever_flagged).and_return reviews
  #     school.stub(:school_ratings).and_return reviews
  #     expect(controller.send :flagged_reviews).to eq(reviews)
  #   end
  #
  #   it 'should return flagged reviews if no school is set' do
  #     reviews = double('reviews')
  #     expect(reviews).to receive(:order).and_return reviews
  #     expect(reviews).to receive(:page).and_return reviews
  #     expect(reviews).to receive(:per).and_return reviews
  #     expect(reviews).to receive(:flagged).and_return reviews
  #
  #     expect(SchoolRating).to receive(:where).with(status: %w[p d r a]).and_return reviews
  #     expect(controller.send :flagged_reviews).to eq(reviews)
  #   end
  # end
  #
  # describe '.load_reported_entities_onto_reviews' do
  #   let(:reviews) { FactoryGirl.build_list(:valid_school_rating, 3) }
  #
  #   it 'should correctly map reported entities to reviews' do
  #     reported_entities = []
  #     reported_entities += FactoryGirl.build_list(:reported_review, 3, reported_entity_id: reviews[0].id)
  #     reported_entities += FactoryGirl.build_list(:reported_review, 2, reported_entity_id: reviews[1].id)
  #     reported_entities += FactoryGirl.build_list(:reported_review, 1, reported_entity_id: reviews[2].id)
  #
  #     controller.class.send :load_reported_entities_onto_reviews, reviews, reported_entities
  #
  #     expect(reviews[0].reported_entities.size).to eq(3)
  #     expect(reviews[1].reported_entities.size).to eq(2)
  #     expect(reviews[2].reported_entities.size).to eq(1)
  #   end
  #
  #   it 'handles empty arrays and nils' do
  #     controller.class.send :load_reported_entities_onto_reviews, [], []
  #     controller.class.send :load_reported_entities_onto_reviews, [], nil
  #     controller.class.send :load_reported_entities_onto_reviews, nil, []
  #     controller.class.send :load_reported_entities_onto_reviews, nil, nil
  #   end
  # end
  #
  # describe '#reported_entities_for_reviews' do
  #   it 'should ask for reported entities' do
  #     reviews = double('reviews')
  #     expect(ReportedEntity).to receive(:find_by_reviews).and_return reviews
  #     expect(reviews).to receive(:order).and_return reviews
  #     controller.class.send :reported_entities_for_reviews, reviews
  #   end
  # end

end
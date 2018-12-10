require 'spec_helper'

describe Api::SavedSchoolsController do  
  describe "POST #create" do
    before(:each) do 
      clean_dbs :gs_schooldb
    end
    let(:user) { FactoryGirl.build(:user) }
    let(:school) { FactoryGirl.build(:school) }

    context "with valid attributes" do
      it "saves the favorite school in the database" do
        Api::SavedSchoolsController.any_instance.stub(:current_user).and_return(user)
        allow(School).to receive_message_chain(:active,:find_by).and_return(school)
        post :create, school: {state: school["state"], id: school["id"]&.to_i}
        expect(JSON.parse(response.body).dig("status")).to eq(200)
        expect(FavoriteSchool.count).to eq(1) 
      end
    end
    
    context "with invalid attributes" do
      it "does not save the new favorite school in the database" do
        Api::SavedSchoolsController.any_instance.stub(:current_user).and_return(user)
        allow(School).to receive_message_chain(:active,:find_by).and_return(nil)
        allow(FavoriteSchool).to receive_message_chain(:create_saved_school_instance).and_return(FavoriteSchool.new)
        post :create, school: {state: "ca", id: 15}
        expect(JSON.parse(response.body).dig("status")).to eq(400)
        expect(FavoriteSchool.count).to eq(0) 
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      clean_dbs :gs_schooldb
    end
    let(:user) { FactoryGirl.build(:user) }
    let(:favorite_school) { FactoryGirl.create(:favorite_school, member_id: user.id) }
    
    context "with valid attributes" do
      it "deletes the entry from the database" do
        Api::SavedSchoolsController.any_instance.stub(:current_user).and_return(user)
        favorite_school
        expect(FavoriteSchool.count).to eq(1) 
        delete :destroy, school: {state: favorite_school.state&.downcase, id: favorite_school.school_id}        
        expect(JSON.parse(response.body).dig("status")).to eq(200)
        expect(FavoriteSchool.count).to eq(0) 
      end
    end

    context "with invalid attributes" do
      it "responds with an error status code" do
        Api::SavedSchoolsController.any_instance.stub(:current_user).and_return(user)
        favorite_school
        allow(FavoriteSchool).to receive_message_chain(:find_by).and_return(nil)
        delete :destroy, school: {state: favorite_school.state&.downcase, id: favorite_school.school_id}
        expect(JSON.parse(response.body).dig("status")).to eq(400)
        expect(FavoriteSchool.count).to eq(1)
      end
    end
  end

end
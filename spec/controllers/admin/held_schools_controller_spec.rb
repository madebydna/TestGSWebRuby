require 'spec_helper'

describe Admin::HeldSchoolsController do
  it 'should include AdminSortable methods' do
    expect(controller).to respond_to :sort_column
    expect(controller).to respond_to :sort_direction
    expect(controller).to respond_to :default_direction
  end

  describe '#index' do
    before do
      setup_held_schools
    end
    after do
      clean_dbs :gs_schooldb
    end
    context "with no parameters" do
      it 'returns held schools sorted by school name asc' do
        get :index
        expect(assigns(:held_schools)).to eq([@alpha_school, @beta_school])
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template("index")
      end
    end

    context "with changing the sort direction" do
      it 'returns held schools sorted by school_name desc' do
        get :index, { direction: "desc", sort: "held_school" }
        expect(controller.sort_direction).to eq("desc")
        expect(assigns(:held_schools)).to eq([@beta_school, @alpha_school])
      end
    end

    context "with sorting by hold_date desc" do
      it "returns held schools sorted by hold_date desc" do
        get :index, { direction: "desc", sort: "hold_date" }
        expect(controller.sort_direction).to eq("desc")
        expect(controller.sort_column).to eq("placed_on_hold_at")
        expect(assigns(:held_schools)).to eq([@alpha_school, @beta_school])
      end
    end

    context "with sorting by hold_date asc" do
      it "returns held schools sorted by hold_date desc" do
        get :index, { direction: "asc", sort: "hold_date" }
        expect(controller.sort_direction).to eq("asc")
        expect(controller.sort_column).to eq("placed_on_hold_at")
        expect(assigns(:held_schools)).to eq([@beta_school, @alpha_school])
      end
    end

    context "with pagination" do
      it "should send page number to model scope" do
        expect(HeldSchool).to receive(:all_active_with_school).
          with(
            order_by: "school_name",
            order_dir: "asc",
            page: 10,
            per_page: 50
          )
        get :index, { page: 10 }
      end
    end

    def setup_held_schools
      school_a = create(:school_record, name: "Alpha School", state: "CA", school_id: 1)
      school_b = create(:school_record, name: "Beta School", state: "MI", school_id: 100)
      @alpha_school = create(:held_school, state: school_a.state, school_id: school_a.school_id, placed_on_hold_at: "2020-01-01T00:00:00")
      @beta_school = create(:held_school, state: school_b.state, school_id: school_b.school_id, placed_on_hold_at: "2019-01-01T00:00:00")
    end
  end
end
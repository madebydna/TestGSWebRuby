require "spec_helper"

describe GsdataLoading::Update do
  let(:valid_blob) do
    {
      :"value" => "63",
      :"state" => "mi",
      :"entity_level" => "school",
      :"school_id" => "00790",
      :"district_id" => "03010",
      :"data_type_id" => 245,
      :"proficiency_band_id" => "null",
      :"cohort_count" => "54",
      :"grade" => "3",
      :"active" => 1,
      :"breakdowns" => [
        {
          :"id" => 1
        }
      ],
      :"academics" => [
        {
          :"id" => 1
        }
      ],
      :"source" => {
        :"source_name" => "MI DOE",
        :"date_valid" => "2017-01-01 00:00:00",
        :"notes" => "DXT-2542 MI MSTEP 2017"
      },
      :"year" => 2017,
      :"configuration" => "feeds"
    }
  end

  describe '#validate' do
    @valid_blob = {
      :"value" => "63",
      :"state" => "mi",
      :"school_id" => "00790",
      :"data_type_id" => 245,
      :"active" => 1,
      :"source" => {
        :"source_name" => "MI DOE",
        :"date_valid" => "2017-01-01 00:00:00",
        :"notes" => "DXT-2542 MI MSTEP 2017"
      }
    }

    {
      nil => false,
      {} => false,
      {
        :"value" => "63",
        :"state" => "mi",
        :"school_id" => "00001",
        :"data_type_id" => 245,
        :"active" => 1,
        :"source" => {
          :"source_name" => "MI DOE",
          :"date_valid" => "2017-01-01 00:00:00",
          :"notes" => "DXT-2542 MI MSTEP 2017"
        }
      } => true,
      {
        :"value" => "63",
        :"state" => "mi",
        :"district_id" => "00001",
        :"data_type_id" => 245,
        :"active" => 1,
        :"source" => {
          :"source_name" => "MI DOE",
          :"date_valid" => "2017-01-01 00:00:00",
          :"notes" => "DXT-2542 MI MSTEP 2017"
        }
      } => true,
      @valid_blob.except(:source) => false,
      @valid_blob.except(:value) => false,
      @valid_blob.except(:state) => false,
      @valid_blob.except(:data_type_id) => false,
      @valid_blob.except(:active) => false,
    }.each do |blob, valid|
      if valid
        it "#{JSON.pretty_unparse(blob)} should validate" do
          expect { GsdataLoading::Update.new(blob).validate }.to_not raise_error
        end
      else
        it "#{JSON.pretty_unparse(blob)} should not validate" do
          expect { GsdataLoading::Update.new(blob).validate }.to raise_error(JSON::Schema::ValidationError)
        end
      end
    end
  end

  describe '#create' do
    after do
      clean_dbs :gs_schooldb, :gsdata, :ca
    end
    let(:blob) do
      {
        :"value" => "63",
        :"state" => school.state,
        :"school_id" => school.state_id,
        :"data_type_id" => 245,
        :"active" => 1,
        :"source" => {
          :"source_name" => "MI DOE",
          :"date_valid" => "2017-01-01 00:00:00",
          :"notes" => "DXT-2542 MI MSTEP 2017"
        }
      }
    end
    let(:update) { GsdataLoading::Update.new(blob) }
    subject { update.create }

    context 'with a valid school' do
      let(:school) { FactoryGirl.create(:alameda_high_school, state_id: '00001') }
      it "saves a data value" do
        expect { subject }.to change { DataValue.count }.from(0).to(1)
      end

      context 'with breakdowns' do
        let(:breakdown) do
          Breakdown.new(name: 'foo').tap(&:save)
        end
        let(:update) do
          GsdataLoading::Update.new(blob.merge(breakdowns: [{'id' => breakdown.id}]))
        end
        it "saves a data_value_to_breakdown" do
          expect { subject }.to change { DataValuesToBreakdown.count }.from(0).to(1)
          expect(DataValuesToBreakdown.first.data_value).to be_present
          expect(DataValuesToBreakdown.first.breakdown).to eq(breakdown)
        end
      end

      context 'with academics' do
        let(:academic) do
          Academic.new(name: 'foo').tap(&:save)
        end
        let(:update) do
          GsdataLoading::Update.new(blob.merge(academics: [{'id' => academic.id}]))
        end
        it "saves a data_value_to_academic" do
          expect { subject }.to change { DataValuesToAcademic.count }.from(0).to(1)
          expect(DataValuesToAcademic.first.data_value).to be_present
          expect(DataValuesToAcademic.first.academic).to eq(academic)
        end
      end
    end
  end

  describe "#state_db" do
    subject do
      GsdataLoading::Update.new(valid_blob.merge(state: 'CA'))
    end
    its(:state_db) { is_expected.to eq(:ca) }
  end
end

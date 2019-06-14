require 'spec_helper'

describe DistrictCharacteristicsCacher do 
    let(:district) { create(:district)}

    after { clean_models(District) }

    context "DIRECTORY_CENSUS_DATA_TYPES" do
        it "should be an array" do
            expect(DistrictCharacteristicsCacher::DIRECTORY_CENSUS_DATA_TYPES).to be_a(Array)
        end

        it "should contain numbers" do
            all_integers = DistrictCharacteristicsCacher::DIRECTORY_CENSUS_DATA_TYPES.all? do |i| 
                i.is_a?(Integer)
            end
            expect(all_integers).to be true
        end

        it "should contain college success data types 443 to 461" do
            (443..461).to_a.all? do |n|
                expect(DistrictCharacteristicsCacher::DIRECTORY_CENSUS_DATA_TYPES).to include(n)
            end
        end
    end

    context "#census_query" do
        subject { DistrictCharacteristicsCacher.new(district) }

        it "should be a CensusDataSetQuery" do
            expect(subject.census_query).to be_a(CensusDataSetQuery)
        end

        it "should construct SQL that filters by configured data types" do
            sql = subject.census_query.relation.to_sql
            data_type_ids = DistrictCharacteristicsCacher::DIRECTORY_CENSUS_DATA_TYPES.join(', ')
            expect(sql).to match(/`census_data_set`.`data_type_id` IN \(#{data_type_ids}\)/)
        end
    end

    context "#build_hash_for_cache" do
        subject { DistrictCharacteristicsCacher.new(district) }

        after { clean_models(CensusDataSet, CensusDataDistrictValue) }

        let(:hash_for_cache) { subject.build_hash_for_cache }

        before do
            # Creates CensusDataSet records for college success data types
            cds1 = create(:census_data_set, data_type_id: 443, year: 2011)
            cds2 = create(:census_data_set, data_type_id: 443, year: 2017)
            cds3 = create(:census_data_set, data_type_id: 450)
            cds4 = create(:census_data_set, data_type_id: 461)

            # And an additional one for a non-included data_type_id
            cds5 = create(:census_data_set, data_type_id: 470)

            # creates CensusDataDistrictValue records for given district and CensusDataSet 
            create(:census_data_district_value_with_newer_data, district_id: district.id, data_set_id: cds1.id)
            create(:census_data_district_value_with_newer_data, district_id: district.id, data_set_id: cds2.id)
            create(:census_data_district_value_with_newer_data, district_id: district.id, data_set_id: cds3.id)
            create(:census_data_district_value_with_newer_data, district_id: district.id, data_set_id: cds4.id)
            create(:census_data_district_value_with_newer_data, district_id: district.id, data_set_id: cds5.id)

            # Mocking out 
            characteristics_mapping = {
                443 => instance_double("CensusDataType", description: "Percent enrolled in any public in-state postsecondary institution within 12 months after graduation"),
                450 => instance_double("CensusDataType", description: "Percent enrolled in any 4 year postsecondary institution within 6 months after graduation"),
                461 => instance_double("CensusDataType", description: "Percent Enrolled in a public 2 year college and Returned for a Second Year"),
                470 => instance_double("CensusDataType", description: "This should not be included")
            }
            allow(CharacteristicsCaching::Base).to receive(:characteristics_data_types).and_return(characteristics_mapping)
        end

        # {"Percent enrolled in any public in-state postsecondary institution within 12 months after graduation"=>
        # [{:breakdown=>"All students", :original_breakdown=>"All students", :district_created=>Sun, 09 Jun 2019 20:40:41 PDT -07:00, :grade=>"9", :district_value=>2.0, :year=>2017}], ....}
        it "should contain college success data types as keys" do
            expect(hash_for_cache).to have_key("Percent enrolled in any public in-state postsecondary institution within 12 months after graduation")
            expect(hash_for_cache).to have_key("Percent enrolled in any 4 year postsecondary institution within 6 months after graduation")
            expect(hash_for_cache).to have_key("Percent Enrolled in a public 2 year college and Returned for a Second Year")
        end

        it "should only have the most recent year per data type" do
            array = hash_for_cache["Percent enrolled in any public in-state postsecondary institution within 12 months after graduation"]
            expect(array.length).to eq(1)
            expect(array.first[:year]).to eq(2017)
        end

        it "should not have entries for data_type_ids not included in DIRECTORY_CENSUS_DATA_TYPES" do
            expect(hash_for_cache).not_to have_key("This should not be included")
        end
    end


end
require 'spec_helper'

describe NearbySchoolsCaching::NearbySchoolsCacher do
  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:schools) do
    school_1 = FactoryGirl.build(:alameda_high_school,id:1)
    allow(school_1).to receive(:great_schools_rating).and_return('8')
    school_2 = FactoryGirl.build(:bay_farm_elementary_school,id:2)
    allow(school_2).to receive(:great_schools_rating)
    [school_1, school_2]
  end
  let(:nearby_schools_cacher) do
    nearby = NearbySchoolsCaching::NearbySchoolsCacher.new(school)
    allow(nearby).to receive(:school_review_count).and_return(12)
    allow(nearby).to receive(:school_review_avg_score).and_return(3)
    allow(nearby).to receive(:school_decorator_obj).and_return('9-12')
    allow(nearby).to receive(:school_media).and_return("Iamveryprettyimage")
    nearby
  end
  # allow(school_2).to receive(:great_schools_rating)
  # let(:school_review_count){ return 12;}
  # let(:school_review_avg_score){ return 3;}


  describe '#build_hash_for_cache' do

    context 'nearby schools cache' do

      #query result
      #[#<School id: 8234, city: "Alameda", level: "9,10,11,12", level_code: "h", name: "Saint Joseph Notre Dame High
      # School", state: "CA", street: "1011 Chestnut Street", type: "private">,
          #<School id: 17573, city: "Oakland", level: "9,10,11,12", level_code: "h", name: "Arise High School", state: "CA", street: "3301 East 12th Street", type: "charter">,
          #<School id: 8208, city: "Oakland", level: "9,10,11,12", level_code: "h", name: "St. Elizabeth High School", state: "CA", street: "1530 34th Avenue", type: "private">,
          #<School id: 14052, city: "Alameda", level: "9,10,11,12", level_code: "h", name: "Alameda Science and Technology Institute", state: "CA", street: "555 Atlantic Avenue", type: "public">,
          #<School id: 11905, city: "Oakland", level: "9,10,11,12", level_code: "h", name: "Life Academy", state: "CA", street: "2101 35th Avenue", type: "public">]

      # expected output alameda high school from cache
      # nbs = {
      #     "nearby_schools" => [
      #         {"id"=>8234,"name"=>"Saint Joseph Notre Dame High School","city"=>"Alameda","state"=>"CA","gs_rating"=>"nr","type"=>"private","level"=>"9-12","review_score"=>4,"review_count"=>16},
      #         {"id"=>17573,"name"=>"Arise High School","city"=>"Oakland","state"=>"CA","gs_rating"=>"2","type"=>"charter","level"=>"9-12","review_score"=>3,"review_count"=>3},
      #         {"id"=>8208,"name"=>"Saint Elizabeth High School","city"=>"Oakland","state"=>"CA","gs_rating"=>"nr","type"=>"private","level"=>"9-12","review_score"=>3,"review_count"=>8},
      #         {"id"=>14052,"name"=>"Alameda Science And Technology Institute","city"=>"Alameda","state"=>"CA","gs_rating"=>"9","type"=>"public","level"=>"9-12","review_score"=>4,"review_count"=>19},
      #         {"id"=>12550,"name"=>"Metwest High School","city"=>"Oakland","state"=>"CA","gs_rating"=>"3","type"=>"public","level"=>"9-12","review_score"=>4,"review_count"=>14}
      #     ]
      # }



      let(:query_results) do
        schools
      end

      let(:expected) do
        [
            {:id=>1,:name=>"Alameda High School",:city=>"Alameda",:state=>"CA",
             :gs_rating=>"8",:type=>"Public district",:level=>"9-12",:school_media=>"Iamveryprettyimage"},
            {:id=>2,:name=>"Bay Farm Elementary School",:city=>"Alameda",:state=>"CA",:gs_rating=>"nr",
             :type=>"Public district",:level=>"9-12",
             :school_media=>"Iamveryprettyimage"}

        ]
      end

      it 'is build correct' do
        allow(nearby_schools_cacher).to receive(:query_results)
                                         .and_return(query_results)
        expect(nearby_schools_cacher.build_hash_for_cache).to eq(expected)
      end
    end
  end

end


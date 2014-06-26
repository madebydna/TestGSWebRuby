require 'spec_helper'

describe SectionHelper do
  describe '#display_section_head_link' do
    let(:school) {
      FactoryGirl.build(:school,
                        id: 1,
                        state: 'mi',
                        city: 'detroit',
                        name: 'a school'
      )
    }

    before(:each) do
      helper.extend(UrlHelper)
      assign(:school, school)
    end

    context 'When category placement is present and there is no layout configuration' do

      context 'When the category placement title is not recognized' do
        let(:category_placement) {FactoryGirl.build(:category_placement, title: 'blah')}

        it 'should not return header link' do
          expect(helper.display_section_head_link(category_placement,'blah')).to be_blank
        end
      end

      context 'When the link_text is not present' do
        let(:category_placement) {FactoryGirl.build(:category_placement, title: 'details')}

        it 'should use category title as text' do
          expect(helper.display_section_head_link(category_placement,nil))
          .to eq("<div class=\"fr prm pt8\"><a href=\"/michigan/detroit/1-A-School/details/\">See all Details</a></div>")
        end
      end

      context 'When the link_text is present' do
        let(:category_placement) {FactoryGirl.build(:category_placement, title: 'details')}

        it 'should return header link' do
          expect(helper.display_section_head_link(category_placement,'See all information'))
          .to eq("<div class=\"fr prm pt8\"><a href=\"/michigan/detroit/1-A-School/details/\">See all information</a></div>")
        end

        it 'should return header link with anchor' do
            expect(helper.display_section_head_link(category_placement,'See all information','enrollment'))
            .to eq("<div class=\"fr prm pt8\"><a href=\"/michigan/detroit/1-A-School/details/#enrollment\">"+
                     "See all information</a></div>")
        end
      end

    end

    context 'When the category placement and its layout configuration are both present' do
      let(:category_placement) {FactoryGirl.build(:category_placement, title: 'details',
                                                  layout_config: {'link_text'=>'See more quality',
                                                                  'link_page'=>'quality'}.to_json)}

      it 'should return header link, with precedence to layout config' do
        expect(helper.display_section_head_link(category_placement,'See all information'))
        .to eq("<div class=\"fr prm pt8\"><a href=\"/michigan/detroit/1-A-School/quality/\">See all information</a></div>")
      end

      context 'When the anchor_link is present' do
        let(:category_placement) {FactoryGirl.build(:category_placement, title: 'details',
                                                    layout_config: {"link_text"=>"See more information",
                                                                    "link_page"=>"quality",
                                                                    "anchor_link"=>"test_scores"}.to_json)}

        it 'should return header link and anchor link' do
          expect(helper.display_section_head_link(category_placement,'See more information'))
          .to eq("<div class=\"fr prm pt8\"><a href=\"/michigan/detroit/1-A-School/quality/#test_scores\">"+
                   "See more information</a></div>")
        end
      end

    end

  end
end
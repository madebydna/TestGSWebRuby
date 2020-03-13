require 'spec_helper'

describe SchoolProfiles::OspSchoolInfo do
  let(:school) { double('school') }
  let(:school_cache_data_reader) { double('school_cache_data_reader') }
  let(:sample_course_data) do
    {
      k1: OpenStruct.new(
          source_name: 'California Department of Education',
          source_year: 2016
      ),
      k2: OpenStruct.new(
          source_name: 'California Department of Education',
          source_year: 2016
      )
    }
  end
  let(:sample_course_props) do
    [
        {
            response_key: 'English',
            response_value: ['English 10', 'English 11']
        },
        {
            response_key: 'STEM',
            response_value: ['Geometry']
        }
    ]
  end
  let(:sample_tab_config) do
    [
        {
            key: :overview,
            title: 'Overview',
            data: [:data],
            source: 'School administration'
        },
        {
            key: :enrollment,
            title: 'Enrollment',
            data: [:data],
            source: 'School administration'
        },
        {
            key: :classes,
            title: 'Classes',
            data: [:data],
            source: 'School administration'
        },
        {
            key: :sports_and_clubs,
            title: 'Sports and clubs',
            data: [:data],
            source: 'School administration'
        }
    ]
  end

  subject(:osp_school_info) { SchoolProfiles::OspSchoolInfo.new(school, school_cache_data_reader) }

  before { allow(osp_school_info).to receive(:data_label) { |param| param } }

  shared_context 'with a claimed school' do
    before { allow(osp_school_info).to receive(:claimed?).and_return(true) }
  end

  shared_context 'with an unclaimed school' do
    before { allow(osp_school_info).to receive(:claimed?).and_return(false) }
  end

  shared_context 'K-12' do
    before { allow(school).to receive(:preschool?).and_return(false) }
  end

  shared_context 'Preschool' do
    before { allow(school).to receive(:preschool?).and_return(true) }
  end

  shared_context 'when OSP has not entered classes' do
    before { allow(osp_school_info).to receive(:has_osp_classes?).and_return(false) }
  end

  shared_context 'when OSP has entered classes' do
    before { allow(osp_school_info).to receive(:has_osp_classes?).and_return(true) }
  end

  shared_context 'when State sources of class info are not available' do
    before { allow(osp_school_info).to receive(:has_non_osp_classes?).and_return(false) }
  end

  shared_context 'when State sources of class info are available' do
    before do
      allow(osp_school_info).to receive(:has_non_osp_classes?).and_return(true)
      allow(osp_school_info).to receive(:courses_by_subject).and_return(sample_course_data)
      allow(osp_school_info).to receive(:courses_props).and_return(sample_course_props)
    end
  end

  # shared_context 'when displaying non-OSP classes' do
  #   before do
  #     allow(osp_school_info).to receive(:show_non_osp_classes?).and_return(true)
  #     allow(osp_school_info).to receive(:courses_by_subject).and_return(sample_course_data)
  #     allow(osp_school_info).to receive(:courses_props).and_return(sample_course_props)
  #   end
  # end

  shared_context 'when displaying OSP classes' do
    before { allow(osp_school_info).to receive(:show_non_osp_classes?).and_return(false) }
  end

  # describe '#show_non_osp_classes?' do
  #   subject(:show_non_osp_classes) { osp_school_info.show_non_osp_classes? }
  #
  #   with_shared_context 'with a claimed school' do
  #     with_shared_context 'when OSP has not entered classes' do
  #       with_shared_context 'when State sources of class info are not available' do
  #         it { should be_falsey }
  #       end
  #
  #       with_shared_context 'when State sources of class info are available' do
  #         it { should be_truthy }
  #       end
  #     end
  #
  #     with_shared_context 'when OSP has entered classes' do
  #       with_shared_context 'when State sources of class info are not available' do
  #         it { should be_falsey }
  #       end
  #
  #       with_shared_context 'when State sources of class info are available' do
  #         it { should be_falsey }
  #       end
  #     end
  #   end
  #
  #   with_shared_context 'with an unclaimed school' do
  #     with_shared_context 'when OSP has not entered classes' do
  #       with_shared_context 'when State sources of class info are not available' do
  #         it { should be_falsey }
  #       end
  #
  #       with_shared_context 'when State sources of class info are available' do
  #         it { should be_truthy }
  #       end
  #     end
  #
  #     with_shared_context 'when OSP has entered classes' do
  #       with_shared_context 'when State sources of class info are not available' do
  #         it { should be_falsey }
  #       end
  #
  #       with_shared_context 'when State sources of class info are available' do
  #         it { should be_truthy }
  #       end
  #     end
  #   end
  # end

  describe '#tab_config' do
    subject(:tab_config) { osp_school_info.tab_config }

    before { allow(osp_school_info).to receive(:osp_school_datas).and_return([:osp_data]) }

    with_shared_context 'with a claimed school' do
      with_shared_context 'K-12' do
        with_shared_context 'when displaying OSP classes' do
          it 'should contain all five tabs' do
            expect(subject.size).to eq(5)
          end

          it 'should contain OSP class data' do
            expect(subject.find { |h| h[:key] == :classes }[:data]).to eq([:osp_data])
          end
        end

        # with_shared_context 'when displaying non-OSP classes' do
        #   it 'should contain all four tabs' do
        #     expect(subject.size).to eq(4)
        #   end
        #
        #   it 'should contain State class data' do
        #     expect(subject.find { |h| h[:key] == :classes }[:data]).to eq(sample_course_props)
        #   end
        # end
      end

      with_shared_context 'Preschool' do
        with_shared_context 'when displaying OSP classes' do
          it 'should contain all four tabs' do
            expect(subject.size).to eq(3)
          end
        end

        # with_shared_context 'when displaying non-OSP classes' do
        #   it 'should contain all four tabs' do
        #     expect(subject.size).to eq(2)
        #   end
        # end
      end
    end

  #   with_shared_context 'with an unclaimed school' do
  #     # with_shared_context 'K-12' do
  #     #   with_shared_context 'when displaying non-OSP classes' do
  #     #     it 'should contain only one tab' do
  #     #       expect(subject.size).to eq(1)
  #     #     end
  #     #
  #     #     it 'should contain State class data' do
  #     #       expect(subject.find { |h| h[:key] == :classes }[:data]).to eq(sample_course_props)
  #     #     end
  #     #   end
  #     # end
  #
  #     with_shared_context 'Preschool' do
  #       with_shared_context 'when displaying non-OSP classes' do
  #         it { should be_empty }
  #       end
  #     end
  #   end
  end

  describe '#sources' do
    subject(:sources) { osp_school_info.sources }
    before { allow(osp_school_info).to receive(:tab_config).and_return(sample_tab_config) }

    with_shared_context 'when displaying OSP classes' do
      it 'should contain sources for all tabs' do
        expect(subject.size).to eq(4)
      end

      it 'classes source should be School administration' do
        expect(subject.find { |h| h[:heading] == 'Classes' }[:names]).to eq(['School administration'])
        expect(subject.find { |h| h[:heading] == 'Classes' }[:years]).to eq([nil])
      end
    end

    # with_shared_context 'when displaying non-OSP classes' do
    #   it 'should contain sources for all tabs' do
    #     expect(subject.size).to eq(4)
    #   end
    #
    #   it 'classes source should be the State' do
    #     expect(subject.find { |h| h[:heading] == 'Classes' }[:names]).to eq(['California Department of Education'])
    #     expect(subject.find { |h| h[:heading] == 'Classes' }[:years]).to eq([2016])
    #   end
    # end
  end

  describe '#data_label' do
    subject(:data_label) { osp_school_info.data_label(str) }
    before { expect(osp_school_info).to receive(:data_label).and_call_original }

    describe 'when given just an ellipsis' do
      let (:str) { '...' }
      it { is_expected.to eq('...') }
    end
  end
end

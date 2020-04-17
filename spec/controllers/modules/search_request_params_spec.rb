# frozen_string_literal: true

require 'spec_helper'

describe SearchRequestParams do
  subject(:search_module) do
    o = Object.new
    o.singleton_class.instance_eval { include SearchRequestParams }
    o
  end

  describe '#district_record' do
    subject { search_module.district_record }

    context 'with no state in request' do
      before do
        expect(search_module).to receive(:state).and_return(nil)
        allow(search_module).to receive(:district_id).and_return(1)
      end

      it { is_expected.to be_nil }
    end

    context 'with no district id or district name in request' do
      before do
        expect(search_module).to receive(:state).and_return('ca')
        expect(search_module).to receive(:district_id).and_return(nil)
        expect(search_module).to receive(:district).and_return(nil)
      end

      it { is_expected.to be_nil }
    end

    context 'with state and district id in request' do
      before do
        allow(search_module).to receive(:state).and_return('ca')
        allow(search_module).to receive(:district_id).and_return(1)
        allow(search_module).to receive(:district).and_return(nil)
      end

      it 'should query for active district by id' do
        ar_stub = double
        district = double
        expect(DistrictRecord).to receive(:by_state).with('ca').and_return(ar_stub)
        expect(ar_stub).to receive(:where).with(district_id: 1).and_return(ar_stub)
        expect(ar_stub).to receive(:first).and_return(district)
        expect(subject).to be(district)
      end
    end

    context 'with state and district name in request' do
      before do
        allow(search_module).to receive(:state).and_return('ca')
        allow(search_module).to receive(:district_id).and_return(nil)
        allow(search_module).to receive(:district).and_return('Oakland Unified')
      end

      it 'should query for active district by name' do
        ar_stub = double
        district = double
        expect(DistrictRecord).to receive(:by_state).with('ca').and_return(ar_stub)
        expect(ar_stub).to receive(:where).with(name: 'Oakland Unified').and_return(ar_stub)
        expect(ar_stub).to receive(:first).and_return(district)
        expect(subject).to be(district)
      end
    end
  end
end

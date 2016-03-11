require 'spec_helper'

describe WithBlock do
  let(:block) do
    proc do |row|
      if /[1-9]/.match(row[:school_code])
        row[:type] = 'school'
      end
      row
    end
  end
  let(:subject) { WithBlock.new(&block) }
  let(:row) do
    { county_code: '00', district_code: '0000', school_code: '0000001' }
  end
  let(:output_row) do
    { county_code: '00', district_code: '0000',
      school_code: '0000001', type: 'school' }
  end
  it 'should call block with row' do
    expect(block).to receive(:call).with(row)
    subject.process(row)
  end
  it 'should evaluate block' do
    expect(subject.process(row)).to eq(output_row)
  end
end

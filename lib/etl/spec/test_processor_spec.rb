require_relative '../test_processor'

describe GS::ETL::TestProcessor do

  subject { described_class.new('dir') }

  it { is_expected.to be }

  context 'when a before block is defined' do
    let(:subclass_inst) do
      Class.new(described_class) do
        before do
          @foo = baz
        end
        def baz()
          'baz'
        end
      end.new('input/dir')
    end

    it 'executes the block in the context of the new instance' do
      expect(subclass_inst.instance_variable_get(:@foo)).to eq 'baz'
    end
  end
end

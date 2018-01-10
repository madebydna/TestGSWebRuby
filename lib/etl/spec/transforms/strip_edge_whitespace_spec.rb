require_relative '../../transforms/strip_edge_whitespace'

describe StripEdgeWhitespace do

  let(:transformer) { StripEdgeWhitespace.new(:foo) }
  let(:row) do
    {
      foo: "\t test \t"
    }
  end

  describe '.initialize' do
    it 'should raise error when field is empty' do
      expect { StripEdgeWhitespace.new(nil) }.to raise_error
    end
    it 'should raise error when which_sides is invalid choice' do
      expect { StripEdgeWhitespace.new(:foo, :none) }.to raise_error
    end
    it 'should return new instance when given valid params' do
      expect(StripEdgeWhitespace.new(:foo, :both)).to be_a(StripEdgeWhitespace)
    end
  end

  describe '#process' do
    subject { transformer.process(row) }
    context 'when which_sides is :left' do
      before { transformer.which_sides = :left }
      it 'should remove whitespace from left' do
        expect(subject[:foo]).to eq("test \t")
      end
    end
    context 'when which_sides is :right' do
      before { transformer.which_sides = :right }
      it 'should remove whitespace from right' do
        expect(subject[:foo]).to eq("\t test")
      end
    end
    context 'when which_sides is :both' do
      before { transformer.which_sides = :both }
      it 'should remove whitespace from both sides' do
        expect(subject[:foo]).to eq("test")
      end
    end
  end

end

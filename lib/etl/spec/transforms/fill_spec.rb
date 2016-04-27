require_relative '../../transforms/fill'

describe Fill do

  #TODO: add #initialize test

  describe "#process" do

    context 'with valid hash' do
      let(:row) do
        {:c => 50, :d => 75}
      end
      let(:fill) do
        Fill.new({:a => 100, :b => 200})
      end

      subject { fill.process(row) }

      it 'is expected to be hash as an end result' do
        expect( subject ).to be_a_kind_of(Hash)
      end

      it 'is expected to be a merge of two hashes' do
        expect( subject ).to eq({:c=>50, :d=>75, :a=>100, :b=>200})
      end

    end

  end

end

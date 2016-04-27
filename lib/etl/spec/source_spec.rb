require_relative '../source'

describe GS::ETL::Source do

  let(:no_context_source) do
    Class.new(GS::ETL::Source) do
      def process(r)
        r+1
      end

      def each
        yield 1
      end
    end.new
  end

  let(:context_source) do
    Class.new(GS::ETL::Source) do
      def process(r)
        r+1
      end

      def each(c)
        yield c
      end
    end.new
  end

  describe '#run' do
    let(:child_step) { GS::ETL::Step.new }

    before do
      no_context_source.add(child_step)
    end

    it 'propagates its records directly to child nodes' do
      expect(child_step).to receive(:propagate).with(1)
      no_context_source.run
    end

    describe 'propagating action' do
      let(:result) { double('result') }
      let(:step) { instance_double('GS::ETL::Step', log_and_process: result) }

      before do
        expect(child_step).to receive(:propagate) do |record, &action|
          @action = action
        end
        no_context_source.run
      end

      context 'passed a single value' do
        let(:row) { double('row') }

        it 'calls the step\'s log_and_process method with the row' do
          expect(@action.call(step, row)).to eq result
          expect(step).to have_received(:log_and_process).with(row)
        end
      end

      context 'passed an array of values' do
        let(:first_row) { double('row') }
        let(:second_row) { double('row') }
        let(:rows) { [first_row, second_row] }

        it 'calls the step\'s log_and_process method on each value' do
          expect(@action.call(step, rows)).to eq [result, result]
          [first_row, second_row].each do |which_row|
            expect(step).to have_received(:log_and_process).with(which_row)
          end
        end
      end
    end

    context 'with a context' do
      let(:context) { double('context') }

      before do
        context_source.add(child_step)
      end

      it 'passes the context to the each method' do
        expect(child_step).to receive(:propagate).with(context)
        context_source.run(context)
      end
    end
  end
end

require_relative '../step'

describe GS::ETL::Step do
  subject { described_class.new }

  describe '#propagate' do
    let(:value) { double('value') }
    let(:propagated_action) { ->(step, val) { val } }
    let(:invoke) { subject.propagate([value], &propagated_action) }

    context 'with a single child' do
      let(:child_step) { described_class.new }

      before do
        subject.add(child_step)
      end

      it 'calls the passed-in block with itself and the propagated value' do
        [subject, child_step].each do |step_type|
          expect(propagated_action).to receive(:call).with(step_type, [value])
            .ordered.and_call_original
        end
        invoke
      end

      it 'does not clone the passed in value' do
        expect(child_step).to receive(:propagate).with([value]) do |*args, &block|
          expect(block).to eq propagated_action
        end
        invoke
      end
    end

    context 'with multiple children' do
      let(:child_steps) do (1..3).map { described_class.new } end

      before do
        allow(value).to receive(:clone).and_return(0, 1, 2)
        child_steps.each { |step| subject.add(step) }
      end

      it 'clones the result of propagated_action' do
        child_steps.each_with_index do |child, index|
          expect(child).to receive(:propagate).with([index]) do |*args, &block|
            expect(block).to eq propagated_action
          end
        end
        invoke
      end
    end
  end
end

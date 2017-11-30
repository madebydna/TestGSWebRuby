require_relative '../step'
require_relative '../row'

describe GS::ETL::Step do

  let(:fake_step_class) { Class.new(described_class) }

  describe '#add_step' do
    it 'returns an instance of given step class' do
      expect(subject.add_step('A description', fake_step_class)).to be_a(fake_step_class)
    end

    it 'adds the new step as a child' do
      new_step = subject.add_step('A description', fake_step_class)
      expect(subject.children.size).to eq(1)
      expect(subject.children.first).to eq(new_step)
    end
  end

  describe '#log_and_process' do
    let(:logger) { double(log_event: nil) }

    before do
      allow(subject).to receive(:logger).and_return(logger)
    end

    it 'should not do anything if row is nil' do
      subject.log_and_process(nil)
      expect(logger).to_not have_received(:log_event)
    end

    it 'when given row, it should record event and process row' do
      row = {foo: :bar}
      subject.log_and_process(row)
      stub_const('GS::ETL::Logging', double(logger: logger))
      expect(logger).to have_received(:log_event).with(
        include(
          id: subject.id,
          step: GS::ETL::Step,
          key: 'Implement #event_key on GS::ETL::Step',
          value: :executed
        )
      )
    end
  end

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
      let(:child_steps) do
        (1..3).map { described_class.new }
      end

      before do
        allow(value).to receive(:clone).and_return(0, 1, 2)
        child_steps.each { |step| subject.add(step) }
      end

      it 'clones the results of the propagated_action' do
        child_steps.each_with_index do |child, index|
          expect(child).to receive(:propagate).with([index]) do |*args, &block|
            expect(block).to eq propagated_action
          end
        end
        invoke
      end
    end
  end

  describe '#record' do
    let(:logger) { double(log_event: nil) }
    before do
      allow(subject).to receive(:logger).and_return(logger)
    end

    it 'tells the event log to process (with correct input data)' do
      subject.id = 10
      event_hash = {
        id: 10,
        step: GS::ETL::Step.class,
        key: 'my key',
        value: 'val'
      }
      subject.record(GS::ETL::Row.new({}, 1), 'val', 'my key')
      expect(logger).to have_received(:log_event).with(include(event_hash))
    end
  end

  describe '#add' do
    let(:step) { GS::ETL::Step.new }
    let(:result) { subject.add(step) }
    before { result }

    it 'should return the added step' do
      expect(result).to eq step
    end

    it 'should add a child step' do
      expect(subject.children.first).to eq(step)
    end

    it 'should set the step''s parent to this step' do
      expect(step.parents).to include(subject)
    end
  end
end

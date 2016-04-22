require 'spec_helper'
require 'step'

describe GS::ETL::Step do
  let(:fake_step_class) do 
    Class.new(GS::ETL::Step)
  end

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
    let(:logger) { double(log: nil) }
    before do
      allow(subject).to receive(:logger).and_return(logger)
    end

    it 'should not do anything if row is nil' do
      subject.log_and_process(nil)
      expect(logger).to_not have_received(:log)
    end

    it 'when given row, it should record event and process row' do
      row = {foo: :bar}
      subject.log_and_process(row)
      stub_const('GS::ETL::Logging', double(logger: logger))
      expect(logger).to have_received(:log).with(
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
    context 'given a root node with two children' do
      let(:root) { subject } 
      let!(:leaf1) { subject.add_step('A description', fake_step_class) }
      let!(:leaf2) { subject.add_step('A description', fake_step_class) }

      it 'should pass the row through each node' do
        row = {foo: :bar}
        enumerated_steps = []
        processed_row = root.propagate(row) do |step, r|
          enumerated_steps << step
          expect(r).to eq(row)
          r
        end
        expect(enumerated_steps - [root, leaf1, leaf2]).to be_empty
      end

      it 'object changes in one node dont affect sibling nodes' do
        row = {foo: :bar}
        enumerated_steps = []
        processed_row = root.propagate(row.clone) do |s, r|
          enumerated_steps << s
          expect(r).to eq(row)
          if s == leaf1
            r.delete(:foo)
          end
          r
        end
        expect(enumerated_steps - [root, leaf1, leaf2]).to be_empty
      end
    end
  end

  describe '#record' do
    let(:logger) { double(debug: nil) }
    allow(subject).to receive(:logger).and_return(logger)

    it 'tells the event log to process (with correct input data)' do
      subject.id = 10
      event_hash = {
        id: 10,
        step: GS::ETL::Step.class,
        key: 'my key',
        value: 'val'
      }
      subject.record('val', 'my key')
      expect(event_log).to have_received(:process).with(event_hash)
    end
  end

  describe '#add' do
    let(:step) { GS::ETL::Step.new }
    it 'should add a child step' do
      subject.add(step)
      expect(subject.children.first).to eq(step)
    end
    it 'should set the step''s parent to this step' do
      subject.add(step)
      expect(step.parents).to include(subject)
    end
  end

end

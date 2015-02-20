require 'spec_helper'

describe SnapshotDecorator do
  let(:school) do
    s = FactoryGirl.build(:school)
    allow(s).to receive(:district).and_return(FactoryGirl.build(:district))
    s
  end
  subject(:snapshot_decorator) do
    SnapshotDecorator.decorate(
      snapshot_hash,
      context: {
        school: school
      }
    )
  end
  let(:snapshot_hash) do
    {
      'data point' => {
        label: 'a label',
        school_value: '50.5'
      }
    }
  end

  describe '#format_label' do
    it 'should capitalize the first letter' do
      expect(subject.format_label('a label')).to eq 'A label'
    end

    it 'should handle a label that starts with a number' do
      expect(subject.format_label('123 abc')).to eq '123 abc'
    end
  end

  describe '#format_value' do
    it 'by default, it should leave numeric value alone' do
      expect(subject.format_value('data point', 50.5)).to eq 50.5
    end

    it 'it should capitalize the first letter if it is not "no info"' do
      expect(subject.format_value('data point', 'no info')).to eq 'no info'
      expect(subject.format_value('data point', 'foo')).to eq 'Foo'
      expect(subject.format_value('data point', 'foo bar')).to eq 'Foo bar'
      expect(subject.format_value('data point', '123 bar')).to eq '123 bar'
    end

    it 'should link the district name if it exists' do
      expect(subject.format_value('district', 'blah')).to match '<a'
    end

    context 'When data point is configured to display as integer' do
      let(:config) do
        {
          'data point' => {
            'format' => 'integer'
          }
        }
      end

      subject(:snapshot_decorator) do
        SnapshotDecorator.decorate(snapshot_hash, context: { config: config } )
      end

      it 'should round a numeric value to an interger' do
        expect(subject.format_value('data point', 50.5)).to eq 51
      end
    end

    it 'should sanitize the provided value' do
      result = subject.format_value('head official name', '<script>alert(1);</script>')
      expect(result).to_not match '<script>'
    end

    it 'the return value should be html_safe' do
      result = subject.format_value('head official name', '<script>alert(1);</script>')
      expect(result).to be_html_safe
    end

    it 'should not escape the html tags that the method wrapped around the user-provided value' do
      result = subject.format_value('head official name', '<div>blah</div>')
      expect(result).to match '<span class=\'notranslate\'>'
    end
  end

end
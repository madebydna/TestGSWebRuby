require 'spec_helper'

describe '_snapshot.html.erb' do

  describe 'html safety' do
    let(:data) do
      [
        enrollment: {
          school_value: 130.0,
          label: 'Students enrolled'
        },
        'head official name' => {
          school_value: 'LINDA BROOKS',
          label: 'School leader'
        }
      ]
    end

    let(:category_placement) do
      double(
        'category_placement',
        layout_config_json: {
          foo: :bar
        }
      )
    end

    before do
      view.extend(UrlHelper)
      view.instance_variable_set(:@school, FactoryGirl.build(:alameda_high_school))
    end

    subject do
      render :partial => 'data_layouts/snapshot',
             locals: {
               data: data, category_placement: category_placement
             }
      rendered
    end

    it 'should not call the raw helper in order to mark values as html_safe' do
      expect(view).to_not receive(:raw)
      subject
    end

    it 'should only render html-safe values' do
      data.first['head official name'][:school_value] = '<script>alert(1);</script>'
      expect(subject).to_not have_content('<script>')
    end

    it 'should escape tags in user provided data' do
      data.first['head official name'][:school_value] = '<table>blah</table>'
      expect(subject).to_not have_content('<table>')
    end

    it 'should have a notranslate tag wrapped around the user input' do
      data.first['head official name'][:school_value] = '<table>blah</table>'
      expect(subject).to match '<span class=\'notranslate\'>'
    end
  end

end


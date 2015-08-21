require 'spec_helper'

describe HandlebarsHelper do

  describe '#t_scope_for' do

    {
      'app/views/handlebars/X/_Y.html.erb' => 'X.Y',
      'app/views/handlebars/X/Y/_Z.html.erb' => 'X.Y.Z',
      'app/views/handlebars/W/X/Y/_Z.html.erb' => 'W.X.Y.Z',
    }.each do |file_path, scope|
      it "should handle #{file_path}" do
        expect(helper.t_scope_for(file_path)).to eq scope
      end
    end
  end
end

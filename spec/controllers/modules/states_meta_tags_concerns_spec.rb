# frozen_string_literal: true

require 'spec_helper'

describe StatesMetaTagsConcerns do
  subject(:state_module) do
    o = Object.new
    o.singleton_class.instance_eval { include StatesMetaTagsConcerns }
    o
  end

  # describe 'current year' do
  #   before do
  #     state_module.instance_variable_set(:@state, {:short => 'az', :long => 'arizona'})
  #     expect(state_module).to receive(:t).and_return(I18n.t('states.show.title', state_long_name_with_caps: 'Arizona'))
  #   end
  #
  #   # it 'should be updated before 2020' do
  #   #   # If this fails then whoever currently owns our SEO strategy should be informed that these
  #   #   # title/meta tags are out of date. They wanted it to say 2019 when we launched in 2018
  #   #   # which is why we aren't using Time.now.year currently.
  #   #   expect(state_module.states_show_title.scan(/\d+/).first.to_i).to be >= Time.now.year
  #   # end
  # end
end

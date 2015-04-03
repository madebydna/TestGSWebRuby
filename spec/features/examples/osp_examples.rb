require 'spec_helper'
require 'features/examples/osp_examples'
require 'features/examples/page_examples'

shared_examples_for 'the conditional multi select group of questions should be disabled' do
  include_example 'should be disabled'
end

shared_examples_for 'Before Care and Canoe buttons should be active' do
  subject do
    answers = Regexp.new(selected_answers.join('|'))
    osp_page.osp_form.checkboxes(text: answers)
  end
  context 'The Before Care and Canoe buttons' do
    include_example 'should contain the active class'
  end
end

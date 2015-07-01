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

shared_example 'should only have one active button' do
  expect(subject.active_buttons.count).to eql 1
end

shared_example 'should have nav bar with school name' do
  subject.find('.rs-osp_school_name', text: school.name.upcase)
end

shared_example 'should have school address' do
  subject.find('.rs-school_address', text:school.street)
end

shared_example 'should have basic school information' do
  subject.find('.rs-school-information', text: school.level)
  subject.find('.rs-school-information', text: school.type.capitalize + ' district')
  subject.find('.rs-school-information', text: school.city)
  subject.find('.rs-school-information', text: school.state)
end

shared_example 'should have a save edits button' do |count|
  subject.assert_selector('button.rs-submit', :count => count)
end

shared_example 'should only contain the following values in the form response' do | *matches |
  fail unless subject.present?

  [*subject].each do |response|
    response.each do |key, answers|
      answers.each do |answer|
        expect(answer['value']).to match Regexp.new(matches.flatten.join('|'))
      end
    end
  end
end

shared_example 'should not submit value in text field' do
  response_before_click = page.response_headers['X-Request-Id']
  osp_page.osp_form.submit.click
  response_after_click = page.response_headers['X-Request-Id']
  expect(response_before_click).to eql(response_after_click)
end

shared_example 'should have switch schools link' do
  subject.find_link('switch schools')
end

shared_example 'should have go to school profile button' do
  subject.find_button('Go to school profile', exact: true)
  end

shared_example 'should have post a message button' do
  subject.find_button('Post a message', exact: true)
end

shared_example 'should have go to school profile link' do
  subject.find_link('Go to school profile', exact: true)
  end

shared_example 'should have post a message link' do
  subject.find_link('Post a message', exact: true)
  end

shared_example 'should have need help link' do
  subject.find_link('Need help?', exact: true)
  end

shared_example 'should have save edits link' do
  subject.find_link('Save edits', exact: true)
end

shared_example 'should display calendar picker' do
  page.find('.datepicker')
end

shared_example 'should have element with text' do | element, text|
  subject.find( element, text: text, exact: true)
end

shared_example 'should have link' do |link, url|
  subject.click_link(link, :href => url)
end

shared_example 'should have link text on page' do |text|
  subject.find_link(text, exact: true)
end

shared_example 'should have field on page with text' do |field, text|
  subject.has_field?(field, :type => text)
end

shared_example 'should have field on page' do |field, type|
  expect(subject).to have_field(field, :type => type)
end

shared_example 'should not have field on page' do |field, type|
  expect(subject).to have_no_field(field, :type => type)
end



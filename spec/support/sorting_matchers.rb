require 'rspec/expectations'

RSpec::Matchers.define :be_in_ascending_order do
  match do |enumerable|
    enumerable.sort == enumerable
  end
end

RSpec::Matchers.define :be_in_descending_order do
  match do |enumerable|
    enumerable.sort.reverse == enumerable
  end
end


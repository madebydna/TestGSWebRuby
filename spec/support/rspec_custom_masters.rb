RSpec::Matchers.define :be_boolean do
  match do |actual|
    expect(actual).to satisfy { |x| x == true || x == false }
  end
end

RSpec::Matchers.define :memoize do |call|
  # This won't work for the memoization of symbols
  match do |subject|
    id_1 = subject.send(call).object_id
    id_2 = subject.send(call).object_id

    expect(id_1).to eq id_2
  end

  failure_message do |subject|
    "Expected #{call} to be memoized. Subsequent calls to #{call} returned different objects, but it should always return same object."
  end
end

RSpec::Matchers.define :round_to do |expected, decimal_places|
  match do |actual|
    expect(actual).to satisfy { |f| f.round(decimal_places || 0) == expected }
  end
end

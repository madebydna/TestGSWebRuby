shared_example 'user should have list' do |user_or_email, list|
  expect_user_subscription(user_or_email, list, true)
end

shared_example 'user should not have list' do |user_or_email, list|
  expect_user_subscription(user_or_email, list, false)
end

def expect_user_subscription(user_or_email, list, expectation)
  user = parse_user_email(user_or_email)
  # Set school using let
  if user.subscriptions.present?
    if school
      expect(user.has_subscription?(list, school)).to be expectation
    else
      expect(user.has_subscription?(list)).to be expectation
    end
  end
end

def parse_user_email(user_or_email)
  if user_or_email.is_a?(User)
    user_or_email
  else
    User.where(email: user_or_email).first
  end
end

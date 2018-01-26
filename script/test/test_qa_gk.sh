CAPYBARA_HOST=https://qa.greatschools.org \
CAPYBARA_PORT=80 \
BLACK_BOX=true \
bundle exec rspec \
--require spec_helper.rb \
--tag=remote \
--pattern="spec/qa/pages/gk/**{,/*/**}/*_spec.rb" \




# If you edit this, be careful not to run the wrong specs and have
# data inserted into the live database!
# Specs that don't write data are tagged as "safe_for_prod"
CAPYBARA_HOST=https://admin.greatschools.org \
CAPYBARA_PORT=80 \
BLACK_BOX=true \
bundle exec rspec \
--require spec_helper.rb \
--tag=safe_for_prod \
--pattern="spec/qa/pages/**{,/*/**}/*_spec.rb" \
--exclude-pattern="spec/qa/pages/gk/**{,/*/**}/*_spec.rb"



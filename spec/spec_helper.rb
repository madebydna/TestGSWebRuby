ENV["RAILS_ENV"] = 'test'
ENV['coverage'] = 'true'

require 'rubygems'

require 'simplecov'
if ENV['JENKINS_URL'] # on ci server
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
elsif ENV['coverage']
  require 'simplecov-html'
  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
end

if ENV['JENKINS_URL'] || ENV['coverage']
  SimpleCov.start 'rails' do
    add_group 'Changed' do |source_file|
      `git ls-files --exclude-standard --others \
        && git diff --name-only \
        && git diff --name-only --cached`.split("\n").detect do |filename|
        source_file.filename.ends_with?(filename)
      end
    end
    add_filter '/spec/'
    add_filter '/config/'
    add_filter 'lib/test_connection_management.rb'
  end
end

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'database_cleaner'
require 'capybara/rspec'
require 'factory_girl'


def monkey_patch_database_cleaner
  DatabaseCleaner::ActiveRecord::Base.module_eval do
    # For some reason, by default database_cleaner will re-load the database.yml file, but we modify
    # Rails' db configuration after database.yml is loaded by the Rails environment.
    #
    # Instead of letting database_cleaner reload database.yml, just tell it to use the config that is already loaded
    def load_config
      if self.db != :default && self.db.is_a?(Symbol)
        @connection_hash = ::ActiveRecord::Base.configurations['test'][self.db.to_s]
      end
    end
  end
end

def define_opposing_examples(name, &proc)
  shared_examples_for name do |positive_or_negative_assertion = true|
    should_execute_positive_assertion = (positive_or_negative_assertion == true)
    if should_execute_positive_assertion
      it name do
        instance_exec &proc
      end
    else
      it "should not #{name}" do
        new_source = proc.to_source(strip_enclosure: true).gsub('.to', '.to_not')
        new_proc = Proc.new { eval(new_source) }
        instance_exec &new_proc
      end
    end
  end
end

def generate_examples_from_hash(hash)
  hash.each_pair do |context, expectations|
    context context do
      include_context context
      expectations.each_pair do |expectation, args|
        include_examples expectation.to_s, *args
      end
    end
  end
end

def shared_example(name, &block)
  params = block.parameters.map(&:last)
  if params.present?
    eval <<-HEREDOC
      shared_examples_for '#{name}' do |#{params.join(',')}|
        it '#{name}' do
          instance_exec #{params.join(',')}, &block
        end
      end
    HEREDOC
  else
    shared_examples_for name do
      it name, &block
    end
  end
end

def with_shared_context(name, *args, &block)
  js_arg = process_args(args)
  describe *[name, js_arg].compact do
    include_context name, *args
    instance_exec &block
  end
end

def when_I(name, *args, &block)
  js_arg = process_args(args)
  describe *[name, js_arg].compact do
    before do
      page_object.send(name.to_s.gsub(' ', '_'), *args)
    end
    instance_exec &block
  end
end

def on_subject(name, *args, &block)
  js_arg = process_args(args)
  describe *[name, js_arg].compact do
    before do
      subject.send(name.to_s.gsub(' ', '_'), *args)
    end
    instance_exec &block
  end
end

def with_subject(name, *args, &block)
  js_arg = process_args(args)
  describe *[name, js_arg].compact do
     subject do
       page_object.send(name.to_s.gsub(' ', '_'), *args)
     end
     instance_exec &block
   end
end

def process_args(args)
  args.try(:last).try(:has_key?, :js) ? args.pop : nil
end

def disconnect_connection_pools(db)
  ActiveRecord::Base.connection_handler.connection_pool_list.each do |pool|
    if pool.connections.present? &&
      ( pool.connections.first.
        current_database == "#{db}_test" )
      pool.disconnect!
    end
  end
end

def disconnect_all_connection_pools
  ActiveRecord::Base.connection_handler.connection_pool_list.each do |pool|
    pool.disconnect!
  end
end

# Takes as arguments as list of db names as symbols
def clean_dbs(*args)
  args.each do |db|
    DatabaseCleaner[:active_record, connection: "#{db}_rw".to_sym].strategy = :truncation
    DatabaseCleaner[:active_record, connection: "#{db}_rw".to_sym].clean
    disconnect_connection_pools(db)
  end
end

def clean_models(db, *models)
  unless db.is_a? Symbol
    models = [ db ] + models
    db = nil
  end

  models.each do |model|
    if db
      db_name = db.to_s
      db_name = "_#{db_name}" if States.abbreviations.include?(db_name)
      db_name << '_test'
      model.connection.execute("TRUNCATE #{db_name}.#{model.table_name}")
      disconnect_connection_pools(db_name.sub('_test', ''))
    else
      model.destroy_all
    end
  end
end

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

Capybara::RSpecMatchers::HaveText.class_eval do
  alias_method :failure_message, :failure_message_for_should
  alias_method :failure_message_when_negated, :failure_message_for_should_not
end

# If you change this you'll also need to change the value in test.rb
# Rails.application.routes.default_url_options[:host] = 'test.host'
Rails.application.routes.default_url_options[:host] = 'localhost'
Rails.application.routes.default_url_options[:trailing_slash] = true

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.backtrace_exclusion_patterns = [
    /\/lib\d*\/ruby\//,
    /org\/jruby\//,
    /bin\//,
    /lib\/rspec\/(core|expectations|matchers|mocks)/,
    /gems/
  ]
  config.include Capybara::DSL
  config.include Rails.application.routes.url_helpers
  config.include UrlHelper
  config.include FactoryGirl::Syntax::Methods
  config.include WaitForAjax, type: :feature
  #method to help run both mobile and desktop tests
  #actual width capybara sets seems to be -15, ie: 320 => 305 and 1280 => 1265. height is the same
  def describe_mobile_and_desktop(mobile_size=[320,568], desktop_size=[1280,960], &block)
    describe_mobile(mobile_size, &block)
    describe_desktop(desktop_size, &block)
  end

  def describe_mobile(mobile_size=[320,568], &block)
    describe_block_with_page_resize('mobile', mobile_size, &block)
  end

  def describe_desktop(desktop_size=[1280,960], &block)
    describe_block_with_page_resize('desktop', desktop_size, &block)
  end

  def describe_block_with_page_resize(describe_block_name, screen_size, &block)
    describe describe_block_name, js: true do
      before { page.current_window.resize_to(*screen_size) }
      instance_eval &block
    end
  end

  def its(attribute, *options, &block)
    describe(attribute.to_s) do
      let(:__its_subject) do
        subject.send(attribute)
      end

      def is_expected
        expect(__its_subject)
      end
      alias_method :are_expected, :is_expected

      options << {} unless options.last.kind_of?(Hash)

      example(nil, *options, &block)
    end
  end

  def they(*options, &block)
    describe 'Every element in the subject' do
      before do
        @__pointer = nil
      end

      def are_expected
        expect(@__pointer)
      end

      options << {} unless options.last.kind_of?(Hash)

      example(nil, *options) do
        subject.each do |s|
          @__pointer = s
          instance_eval &block
        end
      end
    end
  end

  # this forces rspec execution to wait until current_url can get run, which is after all requests have finished
  # otherwise, rspec will execute code/examples/blocks before requests finish. This could cause assertions to fail
  # If they execute after database has already been cleaned or before rails has finished processing the request
  def wait_for_page_to_finish
    current_url
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false


  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explictly tag your specs with their type, e.g.:
  #
  #     describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/v/3-0/docs
  config.infer_spec_type_from_file_location!

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # remove support for "should" syntax, since it is deprecated. Use expect syntax instead
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  def include_example(*args, &block)
    include_examples(*args, &block)
  end
  config.alias_it_should_behave_like_to :test_group, ''

  config.mock_with :rspec

  config.around(:each, :caching) do |example|
    # caching = ActionController::Base.perform_caching
    # ActionController::Base.perform_caching = example.metadata[:caching]
    example.run
    Rails.cache.clear
    # ActionController::Base.perform_caching = caching
  end

  config.before(:each) { Rails.cache.clear }
  config.after(:each) do
    Rails.cache.clear
    disconnect_all_connection_pools
  end

  # config.raise_errors_for_deprecations!

  config.before(:each, js: true) do
    page.driver.block_unknown_urls
  end

    # use capybara-webkit
  Capybara.javascript_driver = :webkit

  require 'socket'
  ip_address = '127.0.0.1'
  # Capybara.default_host = "http://test.host:3000"
  # Capybara.app_host = "http://test.host:3000"
  Capybara.default_host = "http://localhost:3001"
  Capybara.app_host = "http://localhost:3001"
  Capybara.server_port = 3001
  Capybara.run_server = true
  ENV_GLOBAL['app_host'] = 'localhost'
  ENV_GLOBAL['gsweb_host'] = 'localhost'
  ENV_GLOBAL['app_port'] = '3001'
  ENV_GLOBAL['gsweb_port'] = '3001'

  DatabaseCleaner.strategy = :truncation
  # This needs to be done after we've loaded an ActiveRecord strategy above
  monkey_patch_database_cleaner
  YAML::ENGINE.yamler = 'syck'
end

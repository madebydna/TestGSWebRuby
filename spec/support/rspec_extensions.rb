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
      method = name.to_s.gsub(' ', '_')
      if page_object.respond_to?(method)
        page_object.send(method, *args)
      elsif subject.respond_to?(method)
        subject.send(method, *args)
      end
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

DEFAULT_SIZE = [1280, 960]

#method to help run both mobile and desktop tests
#actual width capybara sets seems to be -15, ie: 320 => 305 and 1280 => 1265. height is the same
def describe_mobile_and_desktop(mobile_size=[320,568], desktop_size=DEFAULT_SIZE, &block)
  describe_mobile(mobile_size, &block)
  describe_desktop(desktop_size, &block)
end

def describe_mobile(mobile_size=[320,568], &block)
  describe_block_with_page_resize('mobile', mobile_size, &block)
end

def describe_desktop(desktop_size=DEFAULT_SIZE, &block)
  describe_block_with_page_resize('desktop', desktop_size, &block)
end

def describe_block_with_page_resize(describe_block_name, screen_size, &block)
  describe describe_block_name, js: true do
    before { page.current_window.resize_to(*screen_size) }
    instance_eval &block
    after { page.current_window.resize_to(*DEFAULT_SIZE) }
  end
end

def define_ordinal_methods(method_suffix, array)
  %w[first second third fourth fifth].each_with_index do |ordinal, index|
    instance_exec do
      define_method("#{ordinal}_#{method_suffix}") do
        self.send(array)[index]
      end
    end
  end
end

def include_example(*args, &block)
  include_examples(*args, &block)
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
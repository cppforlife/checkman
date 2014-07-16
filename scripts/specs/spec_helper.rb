require "check_shared_examples"

def describe_check(name, file_name=name, &block)
  check_file = check_require(file_name.to_s.downcase)
  check_class = check_file.const_get(name.to_s)

  include CheckSharedExamples

  describe(check_class) do
    subject { described_class.new(*opts) }
    instance_eval(&block)
  end
end

def check_require(name)
  eval_require("#{name}.check")
end

def eval_require(file_name)
  ruby = file_contents(file_name)
  Class.new.tap do |k|
    k.class_eval(ruby, __FILE__, __LINE__)
  end
end

def file_contents(file_name)
  specs_path = File.dirname(File.expand_path(__FILE__))
  file_path = File.join(specs_path, "..", file_name)
  contents = File.read(file_path)
end

require "webmock"
require "stringio"

def capture_stderr
  old_stderr = $stderr
  $stderr = StringIO.new
  yield
  $stderr.string
ensure
  $stderr = old_stderr
end

RSpec.configure do |config|
  config.around(:each) do |example|
    # Checks usually spit out lots of debugging info to stderr
    capture_stderr { example.call }
  end unless ENV["SHOW_STDERR"]

  config.before(:suite) { WebMock.allow_net_connect! }
end

require 'fluent/test'
require 'fluent/test/driver/output'
require 'fluent/test/helpers'
require 'fluent/plugin/out_lambda'
require 'aws-sdk-core'
require 'time'

# Disable Test::Unit
module Test::Unit::RunCount; def run(*); end; end
# prevent Test::Unit's AutoRunner from executing during RSpec's rake task
Test::Unit.run = true if defined?(Test::Unit) && Test::Unit.respond_to?(:run=)

RSpec.configure do |config|
  config.before(:all) do
    Fluent::Test.setup
  end
end

def run_driver(options = {})
  tag = options.delete(:tag) || 'test.default'

  additional_options = options.map {|key, value|
    "#{key} #{value}"
  }.join("\n")

  fluentd_conf = <<-EOS
type lambda
aws_key_id AKIAIOSFODNN7EXAMPLE
aws_sec_key wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
region us-west-1
#{additional_options}
  EOS

  driver = Fluent::Test::Driver::Output.new(Fluent::Plugin::LambdaOutput).configure(fluentd_conf)

  driver.run(default_tag: tag) do
    client = driver.instance.instance_variable_get(:@client)
    yield(driver, client)
  end
end

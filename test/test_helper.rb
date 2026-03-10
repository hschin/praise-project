ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Minitest 6 removed Object#stub — restore it for test isolation
# (minitest 5 behaviour: temporarily replaces a method for the duration of a block)
class Object
  def stub(method_name, val_or_callable = nil, *block_args, &block)
    old_method = begin
      method(method_name)
    rescue NameError
      nil
    end

    define_singleton_method(method_name) do |*args, **kwargs, &inner_block|
      if val_or_callable.respond_to?(:call)
        val_or_callable.call(*args, **kwargs, &inner_block)
      else
        val_or_callable
      end
    end

    yield(*block_args)
  ensure
    if old_method
      define_singleton_method(method_name, old_method)
    else
      remove_method(method_name) rescue nil
    end
  end
end

# Restore Minitest::Mock for stubbed client expectations
module Minitest
  class Mock
    def initialize
      @expected_calls = {}
      @actual_calls = {}
    end

    def expect(name, retval, *args)
      @expected_calls[name] ||= []
      @expected_calls[name] << { retval: retval, args: args.first || [] }
      self
    end

    def method_missing(name, *args, &block)
      if @expected_calls.key?(name)
        call = @expected_calls[name].shift
        @actual_calls[name] ||= []
        @actual_calls[name] << args
        call[:retval]
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      @expected_calls.key?(name) || super
    end

    def verify
      @expected_calls.each do |name, calls|
        raise MockExpectationError, "Expected #{name} to be called #{calls.length} more time(s)" unless calls.empty?
      end
      true
    end
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

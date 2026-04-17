ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    HELD_KARP_SKIP_MESSAGE = "Set SKIP_HELD_KARP to skip expensive exact solver tests"

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def skip_held_karp_if_requested
      skip HELD_KARP_SKIP_MESSAGE if skip_held_karp_tests?
    end

    def skip_held_karp_tests?
      ["1", "true"].include?(ENV.fetch("SKIP_HELD_KARP", "").downcase)
    end
  end
end

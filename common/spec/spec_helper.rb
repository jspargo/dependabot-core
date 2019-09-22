# frozen_string_literal: true

require "rspec/its"
require "webmock/rspec"
require "byebug"

require_relative "dummy_package_manager/dummy"

RSpec.configure do |config|
  config.color = true
  config.order = :rand
  config.mock_with(:rspec) { |mocks| mocks.verify_partial_doubles = true }
  config.raise_errors_for_deprecations!
end

def fixture(*name)
  File.read(File.join("spec", "fixtures", File.join(*name)))
end

def capture_stderr
  previous_stderr = $stderr
  $stderr = StringIO.new
  yield
ensure
  $stderr = previous_stderr
end

# Spec helper to provide GitHub credentials if set via an environment variable
def github_credentials
  if ENV["DEPENDABOT_TEST_ACCESS_TOKEN"].nil?
    []
  else
    [{
      "type" => "git_source",
      "host" => "github.com",
      "username" => "x-access-token",
      "password" => ENV["DEPENDABOT_TEST_ACCESS_TOKEN"]
    }]
  end
end

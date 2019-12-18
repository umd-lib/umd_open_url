# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  # Ignore test files
  add_filter %r{^/test/}
end

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'umd_open_url'

require 'minitest/autorun'
require 'minitest/reporters'
require 'webmock/minitest'
require 'byebug'

Minitest::Reporters.use!

# Set logging level to FATAL so we don't
# have log statements in test output
UmdOpenUrl.logger.level = Logger::FATAL

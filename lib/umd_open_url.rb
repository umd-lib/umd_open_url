# frozen_string_literal: true

require 'umd_open_url/builder'
require 'umd_open_url/resolver'

# Common utilities for the module
module UmdOpenUrl
  def self.logger
    @logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
  end

  def self.logger=(logger)
    @logger = logger
  end
end

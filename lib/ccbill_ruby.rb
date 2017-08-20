require 'ccbill_ruby/version'
require 'ccbill_ruby/configuration'
require 'ccbill_ruby/dynamic_pricing'
require 'ccbill_ruby/postback'

module CCBill
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end
end

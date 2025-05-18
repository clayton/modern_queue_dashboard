# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "bundler/setup"
require "minitest/autorun"
require "minitest/reporters"
require "modern_queue_dashboard"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# Stub SolidQueue models when gem is missing (for unit tests that don't need DB)
unless defined?(SolidQueue)
  module SolidQueue
    class BaseStub
      def self.where(*) = []
      def self.order(*) = self
      def self.limit(*) = self
      def self.pick(*) = nil
      def self.count = 0
      def self.distinct = self
      def self.pluck(*) = []
      def self.column_names = []
    end

    Job = Class.new(BaseStub)
    Execution = Class.new(BaseStub)
    FailedExecution = Class.new(BaseStub)
  end
end

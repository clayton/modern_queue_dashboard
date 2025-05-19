# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "bundler/setup"
require "minitest/autorun"
require "minitest/reporters"
require "modern_queue_dashboard"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# Define ActiveRecord for rescues in tests
unless defined?(ActiveRecord)
  module ActiveRecord
    class StatementInvalid < StandardError; end
  end
end

# Stub SolidQueue models when gem is missing (for unit tests that don't need DB)
unless defined?(SolidQueue)
  module SolidQueue
    class BaseStub
      class WhereChain
        def initialize(parent)
          @parent = parent
        end

        def not(*) = @parent
      end

      def self.where(*)
        self
      end

      def self.not
        WhereChain.new(self)
      end

      def self.order(*) = self
      def self.limit(*) = self
      def self.pick(*) = nil
      def self.count = 0
      def self.distinct = self
      def self.pluck(*) = []
      def self.column_names = []
      def self.joins(*) = self
    end

    Job = Class.new(BaseStub)
    Execution = Class.new(BaseStub)
    FailedExecution = Class.new(BaseStub)
    ReadyExecution = Class.new(BaseStub)
    ScheduledExecution = Class.new(BaseStub)
    ClaimedExecution = Class.new(BaseStub)
  end
end

# frozen_string_literal: true

require 'deimos/utils/db_poller'
require 'deimos/poll_info'
require 'sigurd'

module Deimos
  module Utils
    # Class which continually polls the database and sends Kafka messages.
    module DbPoller
      # Base poller class for retrieving and publishing messages.
      class Base

        # @return [Integer]
        BATCH_SIZE = 1000

        # Needed for Executor so it can identify the worker
        # @return [Integer]
        attr_reader :id

        # @return [Hash]
        attr_reader :config

        # Method to define producers if a single poller needs to publish to multiple topics.
        # Producer classes should be constantized
        # @return [Array<Producer>]
        def self.producers
          []
        end

        # @param config [FigTree::ConfigStruct]
        def initialize(config)
          @config = config
          @id = SecureRandom.hex
          begin
            if @config.poller_class.nil? && @config.producer_class.nil?
              raise 'No producers have been set for this DB poller!'
            end

            @resource_class = @config.producer_class.present? ? @config.producer_class.constantize : @config.poller_class.constantize

            if @config.poller_class.nil?
              unless @resource_class < Deimos::ActiveRecordProducer
                raise "Class #{@resource_class.class.name} is not an ActiveRecordProducer!"
              end
            else
              @resource_class.producers.each do |producer|
                unless producer < Deimos::ActiveRecordProducer
                  raise "Class #{producer.class.name} is not an ActiveRecordProducer!"
                end
              end
            end
          rescue NameError => e
            raise e.message.to_s
          end
        end

        # Start the poll:
        # 1) Grab the current PollInfo from the database indicating the last
        # time we ran
        # 2) On a loop, process all the recent updates between the last time
        # we ran and now.
        # @return [void]
        def start
          # Don't send asynchronously
          if Deimos.config.producers.backend == :kafka_async
            Deimos.config.producers.backend = :kafka
          end
          Deimos.config.logger.info('Starting...')
          @signal_to_stop = false
          ActiveRecord::Base.connection.reconnect! unless ActiveRecord::Base.connection.open_transactions.positive?

          retrieve_poll_info
          loop do
            if @signal_to_stop
              Deimos.config.logger.info('Shutting down')
              break
            end
            process_updates if should_run?
            sleep(0.1)
          end
        end

        # @return [void]
        # Grab the PollInfo or create if it doesn't exist.
        # @return [void]
        def retrieve_poll_info
          @info = Deimos::PollInfo.find_by_producer(@resource_class.to_s) || create_poll_info
        end

        # @return [Deimos::PollInfo]
        def create_poll_info
          Deimos::PollInfo.create!(producer: @resource_class.to_s, last_sent: Time.new(0))
        end

        # Indicate whether this current loop should process updates. Most loops
        # will busy-wait (sleeping 0.1 seconds) until it's ready.
        # @return [Boolean]
        def should_run?
          Time.zone.now - @info.last_sent - @config.delay_time >= @config.run_every
        end

        # Stop the poll.
        # @return [void]
        def stop
          Deimos.config.logger.info('Received signal to stop')
          @signal_to_stop = true
        end

        # Send messages for updated data.
        # @return [void]
        def process_updates
          raise Deimos::MissingImplementationError
        end

        # @param batch [Array<ActiveRecord::Base>]
        # @param status [PollStatus]
        # @return [Boolean]
        def process_batch_with_span(batch, status)
          retries = 0
          span = nil
          begin
            span = Deimos.config.tracer&.start(
              'deimos-db-poller',
              resource: @resource_class.class.name.gsub('::', '-')
            )
            process_batch(batch)
            Deimos.config.tracer&.finish(span)
            status.batches_processed += 1
          rescue Kafka::Error => e # keep trying till it fixes itself
            Deimos.config.logger.error("Error publishing through DB Poller: #{e.message}")
            sleep(0.5)
            retry
          rescue StandardError => e
            Deimos.config.logger.error("Error publishing through DB poller: #{e.message}}")
            if retries < @config.retries
              retries += 1
              sleep(0.5)
              retry
            else
              Deimos.config.logger.error('Retries exceeded, moving on to next batch')
              Deimos.config.tracer&.set_error(span, e)
              status.batches_errored += 1
              return false
            end
          ensure
            status.messages_processed += batch.size
          end
          true
        end

        # If multiple producers, loop through producers configured on poller subclass
        # If single producer, @resource_class will be the constantized producer class
        # @param batch [Array<ActiveRecord::Base>]
        # @return [void]
        def process_batch(batch)
          if @config.producer_class.present?
            @resource_class.send_events(batch)
          else
            @resource_class.producers.each do |producer|
              producer.send_events(batch)
            end
          end
        end

        # Configure log identifier and messages to be used in subclasses
        # # @return [String]
        def log_identifier
          if @config.producer_class.present?
            "#{self.class.name}: #{@resource_class.topic}"
          else
            "#{self.class.name}: #{@resource_class.producers.map(&:topic)}"
          end
        end
      end
    end
  end
end

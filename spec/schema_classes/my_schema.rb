# frozen_string_literal: true

# This file is autogenerated by Deimos, Do NOT modify
module Schemas
  ### Primary Schema Class ###
  # Autogenerated Schema for Record at com.my-namespace.MySchema
  class MySchema < Deimos::SchemaClass::Record
    ### Attribute Readers ###
    # @return [MySchemaKey]
    attr_reader :payload_key

    ### Attribute Accessors ###
    # @param value [String]
    attr_accessor :test_id
    # @param value [Integer]
    attr_accessor :some_int

    ### Attribute Writers ###
    # @param value [MySchemaKey]
    def payload_key=(value)
      @payload_key = MySchemaKey.initialize_from_value(value)
    end

    # @override
    def initialize(test_id: nil,
                   some_int: nil,
                   payload_key: nil)
      super()
      self.test_id = test_id
      self.some_int = some_int
      self.payload_key = payload_key
    end

    # @override
    def schema
      'MySchema'
    end

    # @override
    def namespace
      'com.my-namespace'
    end

    # @override
    def to_h
      {
        'test_id' => @test_id,
        'some_int' => @some_int,
        'payload_key' => @payload_key&.to_h
      }
    end
  end
end

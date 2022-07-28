# frozen_string_literal: true

# This file is autogenerated by Deimos, Do NOT modify
module Schemas; module MyNamespace
  ### Primary Schema Class ###
  # Autogenerated Schema for Record at com.my-namespace.MyNestedSchema
  class MyNestedSchema < Deimos::SchemaClass::Record

    ### Secondary Schema Classes ###
    # Autogenerated Schema for Record at com.my-namespace.MyNestedRecord
    class MyNestedRecord < Deimos::SchemaClass::Record
  
      ### Attribute Accessors ###
      # @return [Integer]
      attr_accessor :some_int
      # @return [Float]
      attr_accessor :some_float
      # @return [String]
      attr_accessor :some_string
      # @return [nil, Integer]
      attr_accessor :some_optional_int
  
      # @override
      def initialize(some_int: nil,
                     some_float: nil,
                     some_string: nil,
                     some_optional_int: nil)
        super
        self.some_int = some_int
        self.some_float = some_float
        self.some_string = some_string
        self.some_optional_int = some_optional_int
      end
  
      # @override
      def schema
        'MyNestedRecord'
      end
  
      # @override
      def namespace
        'com.my-namespace'
      end
  
      # @override
      def as_json(_opts={})
        {
          'some_int' => @some_int,
          'some_float' => @some_float,
          'some_string' => @some_string,
          'some_optional_int' => @some_optional_int
        }
      end
    end


    ### Attribute Readers ###
    # @return [MyNestedRecord]
    attr_reader :some_nested_record
    # @return [nil, MyNestedRecord]
    attr_reader :some_optional_record

    ### Attribute Accessors ###
    # @return [String]
    attr_accessor :test_id
    # @return [Float]
    attr_accessor :test_float
    # @return [Array<String>]
    attr_accessor :test_array

    ### Attribute Writers ###
    # @return [MyNestedRecord]
    def some_nested_record=(value)
      @some_nested_record = MyNestedRecord.initialize_from_value(value)
    end

    # @return [nil, MyNestedRecord]
    def some_optional_record=(value)
      @some_optional_record = MyNestedRecord.initialize_from_value(value)
    end

    # @override
    def initialize(test_id: nil,
                   test_float: nil,
                   test_array: nil,
                   some_nested_record: nil,
                   some_optional_record: nil)
      super
      self.test_id = test_id
      self.test_float = test_float
      self.test_array = test_array
      self.some_nested_record = some_nested_record
      self.some_optional_record = some_optional_record
    end

    # @override
    def schema
      'MyNestedSchema'
    end

    # @override
    def namespace
      'com.my-namespace'
    end

    def self.tombstone(key)
      record = self.new
      record.tombstone_key = key
      record.test_id = key
      record
    end

    # @override
    def as_json(_opts={})
      {
        'test_id' => @test_id,
        'test_float' => @test_float,
        'test_array' => @test_array,
        'some_nested_record' => @some_nested_record&.as_json,
        'some_optional_record' => @some_optional_record&.as_json
      }
    end
  end
end; end

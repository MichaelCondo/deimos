# frozen_string_literal: true

# This file is autogenerated by Deimos, Do NOT modify
module Schemas; module MyNamespace; module Response
  ### Primary Schema Class ###
  # Autogenerated Schema for Record at com.my-namespace.response.Index
  class Index < Deimos::SchemaClass::Record

    ### Attribute Accessors ###
    # @return [String]
    attr_accessor :response_id

    # @override
    def initialize(response_id: nil)
      super
      self.response_id = response_id
    end

    # @override
    def schema
      'Index'
    end

    # @override
    def namespace
      'com.my-namespace.response'
    end

    # @override
    def as_json(_opts={})
      {
        'response_id' => @response_id
      }
    end
  end
end; end; end
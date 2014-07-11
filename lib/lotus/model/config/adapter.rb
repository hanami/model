module Lotus
  module Model
    module Config

      # Adapter configuration
      #
      # @since x.x.x
      # @api private
      class Adapter

        class FormatError < ::StandardError
        end
        # URL of the adapter
        attr_reader :url

        # Class of the adapter
        # Ex: Lotus::Model::Adapters::SqlAdapter
        attr_reader :type

        # Adapter configuration for Lotus::Model
        #
        # @param url URL of the adapter
        # @param [Symbol, String] type Type of the adapter, 
        #   if type is Symbol, it will be inflected from symbol to class
        #   if type is String, it will be constantize.
        #
        # @example
        #   Lotus::Model::Config::Adapter.new('postgres://localhost/db', :sql)
        #     uses Lotus::Model::Adapters::SqlAdapter as adapter's implementation
        #
        #   Lotus::Model::Config::Adapter.new('postgres://localhost/db', 'MyApp::Adapters::MyRemoteApiAdapter')
        #     uses MyApp::Adapters::MyRemoteApiAdapter as adapter's implementation
        #
        def initialize(url, type)
          @url = url
          if type.is_a? Symbol
            @type = Lotus::Utils::Class.load!("Lotus::Model::Adapters::#{Lotus::Utils::String.new(type).classify}Adapter")
          elsif type.is_a? String
            @type = Lotus::Utils::Class.load!(type)
          else
            raise FormatError.new("Type must be String or Symbol")
          end
        end
      end
    end
  end
end

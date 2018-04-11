require 'hanami/utils/string'
require 'hanami/utils/hash'

module Hanami
  module Model
    module Sql
      module Types
        module Schema
          # Coercions for schema types
          #
          # @since 0.7.0
          # @api private
          #
          # rubocop:disable Metrics/ModuleLength
          # rubocop:disable Metrics/MethodLength
          module Coercions
            # Coerces given argument into Integer
            #
            # @param arg [#to_i,#to_int] the argument to coerce
            #
            # @return [Integer] the result of the coercion
            #
            # @raise [ArgumentError] if the coercion fails
            #
            # @since 0.7.0
            # @api private
            def self.int(arg)
              case arg
              when ::Integer
                arg
              when ::Float, ::BigDecimal, ::String, ::Hanami::Utils::String, ->(a) { a.respond_to?(:to_int) }
                ::Kernel.Integer(arg)
              else
                raise ArgumentError.new("invalid value for Integer(): #{arg.inspect}")
              end
            end

            # Coerces given argument into Float
            #
            # @param arg [#to_f] the argument to coerce
            #
            # @return [Float] the result of the coercion
            #
            # @raise [ArgumentError] if the coercion fails
            #
            # @since 0.7.0
            # @api private
            def self.float(arg)
              case arg
              when ::Float
                arg
              when ::Integer, ::BigDecimal, ::String, ::Hanami::Utils::String, ->(a) { a.respond_to?(:to_f) && !a.is_a?(::Time) }
                ::Kernel.Float(arg)
              else
                raise ArgumentError.new("invalid value for Float(): #{arg.inspect}")
              end
            end

            # Coerces given argument into BigDecimal
            #
            # @param arg [#to_d] the argument to coerce
            #
            # @return [BigDecimal] the result of the coercion
            #
            # @raise [ArgumentError] if the coercion fails
            #
            # @since 0.7.0
            # @api private
            def self.decimal(arg)
              case arg
              when ::BigDecimal
                arg
              when ::Integer, ::Float, ::String, ::Hanami::Utils::String
                ::Kernel.BigDecimal(arg, ::Float::DIG)
              when ->(a) { a.respond_to?(:to_d) }
                arg.to_d
              else
                raise ArgumentError.new("invalid value for BigDecimal(): #{arg.inspect}")
              end
            end

            # Coerces given argument into Date
            #
            # @param arg [#to_date,String] the argument to coerce
            #
            # @return [Date] the result of the coercion
            #
            # @raise [ArgumentError] if the coercion fails
            #
            # @since 0.7.0
            # @api private
            def self.date(arg)
              case arg
              when ::Date
                arg
              when ::String, ::Hanami::Utils::String
                ::Date.parse(arg)
              when ::Time, ::DateTime, ->(a) { a.respond_to?(:to_date) }
                arg.to_date
              else
                raise ArgumentError.new("invalid value for Date(): #{arg.inspect}")
              end
            end

            # Coerces given argument into DateTime
            #
            # @param arg [#to_datetime,String] the argument to coerce
            #
            # @return [DateTime] the result of the coercion
            #
            # @raise [ArgumentError] if the coercion fails
            #
            # @since 0.7.0
            # @api private
            def self.datetime(arg)
              case arg
              when ::DateTime
                arg
              when ::String, ::Hanami::Utils::String
                ::DateTime.parse(arg)
              when ::Date, ::Time, ->(a) { a.respond_to?(:to_datetime) }
                arg.to_datetime
              else
                raise ArgumentError.new("invalid value for DateTime(): #{arg.inspect}")
              end
            end

            # Coerces given argument into Time
            #
            # @param arg [#to_time,String] the argument to coerce
            #
            # @return [Time] the result of the coercion
            #
            # @raise [ArgumentError] if the coercion fails
            #
            # @since 0.7.0
            # @api private
            def self.time(arg)
              case arg
              when ::Time
                arg
              when ::String, ::Hanami::Utils::String
                ::Time.parse(arg)
              when ::Date, ::DateTime, ->(a) { a.respond_to?(:to_time) }
                arg.to_time
              when ::Integer
                ::Time.at(arg)
              else
                raise ArgumentError.new("invalid value for Time(): #{arg.inspect}")
              end
            end

            # Coerces given argument into Array
            #
            # @param arg [#to_ary] the argument to coerce
            #
            # @return [Array] the result of the coercion
            #
            # @raise [ArgumentError] if the coercion fails
            #
            # @since 0.7.0
            # @api private
            def self.array(arg)
              case arg
              when ::Array
                arg
              when ->(a) { a.respond_to?(:to_ary) }
                ::Kernel.Array(arg)
              else
                raise ArgumentError.new("invalid value for Array(): #{arg.inspect}")
              end
            end

            # Coerces given argument into Hash
            #
            # @param arg [#to_hash] the argument to coerce
            #
            # @return [Hash] the result of the coercion
            #
            # @raise [ArgumentError] if the coercion fails
            #
            # @since 0.7.0
            # @api private
            def self.hash(arg)
              case arg
              when ::Hash
                arg
              when ->(a) { a.respond_to?(:to_hash) }
                Utils::Hash.deep_symbolize(
                  ::Kernel.Hash(arg)
                )
              else
                raise ArgumentError.new("invalid value for Hash(): #{arg.inspect}")
              end
            end

            # Coerces given argument to appropriate Postgres JSON(B) type, i.e. Hash or Array
            #
            # @param arg [Object] the object to coerce
            #
            # @return [Hash, Array] the result of the coercion
            #
            # @raise [ArgumentError] if the coercion fails
            #
            # @since 1.0.2
            # @api private
            def self.pg_json(arg)
              case arg
              when ->(a) { a.respond_to?(:to_hash) }
                hash(arg)
              when ->(a) { a.respond_to?(:to_a) }
                array(arg)
              else
                raise ArgumentError.new("invalid value for PG_JSON(): #{arg.inspect}")
              end
            end
          end
          # rubocop:enable Metrics/MethodLength
          # rubocop:enable Metrics/ModuleLength
        end
      end
    end
  end
end

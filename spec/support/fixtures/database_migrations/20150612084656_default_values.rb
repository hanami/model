# frozen_string_literal: true

Hanami::Model.migration do
  change do
    case Database.engine
    when :sqlite
      create_table :default_values do
        column :a, Integer,    default: 23
        column :b, String,     default: "Hanami"
        column :c, Fixnum,     default: -1 # rubocop:disable Lint/UnifiedInteger
        column :d, :Bignum,    default: 0
        column :e, Float,      default: 3.14
        column :f, BigDecimal, default: 1.0
        column :g, Numeric,    default: 943_943
        column :h, Date,       default: Date.new
        column :i, DateTime,   default: DateTime.now
        column :j, Time,       default: Time.now
        column :k, TrueClass,  default: true
        column :l, FalseClass, default: false
      end
    when :postgresql
      create_table :default_values do
        column :a, Integer,    default: 23
        column :b, String,     default: "Hanami"
        column :c, Fixnum,     default: -1 # rubocop:disable Lint/UnifiedInteger
        column :d, :Bignum,    default: 0
        column :e, Float,      default: 3.14
        column :f, BigDecimal, default: 1.0
        column :g, Numeric,    default: 943_943
        column :h, Date,       default: "now"
        column :i, DateTime,   default: DateTime.now
        column :j, Time,       default: Time.now
        column :k, TrueClass,  default: true
        column :l, FalseClass, default: false
      end
    when :mysql
      create_table :default_values do
        column :a, Integer,    default: 23
        column :b, String,     default: "Hanami"
        column :c, Fixnum,     default: -1 # rubocop:disable Lint/UnifiedInteger
        column :d, :Bignum,    default: 0
        column :e, Float,      default: 3.14
        column :f, BigDecimal, default: 1.0
        column :g, Numeric,    default: 943_943
        column :h, Date # ,       default: 'CURRENT_TIMESTAMP'
        column :i, DateTime,   default: DateTime.now
        column :j, Time,       default: Time.now
        column :k, TrueClass,  default: true
        column :l, FalseClass, default: false
      end
    end
  end
end

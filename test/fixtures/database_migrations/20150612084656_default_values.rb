Lotus::Model.migration do
  change do
    create_table :default_values do
      column :a, Integer,    default: 23
      column :b, String,     default: "Lotus"
      column :c, Fixnum,     default: -1
      column :d, Bignum,     default: 0
      column :e, Float,      default: 3.14
      column :f, BigDecimal, default: 1.0
      column :g, Numeric,    default: 943943
      column :h, Date,       default: Date.new
      column :i, DateTime,   default: DateTime.now
      column :j, Time,       default: Time.now
      column :k, TrueClass,  default: true
      column :l, FalseClass, default: false
    end
  end
end

Hanami::Model.migration do
  change do
    create_table :column_types do
      column :integer1, Integer
      column :integer2, :integer
      column :integer3, 'integer'

      column :string1, String
      column :string2, :string
      column :string3, 'string'
      column :string4, 'varchar(3)'

      column :string5, String, size: 50
      column :string6, String, fixed: true
      column :string7, String, fixed: true, size: 64
      column :string8, String, text: true

      column :file1, File
      column :file2, 'blob'

      column :number1, Fixnum
      column :number2, Bignum
      column :number3, Float
      column :number4, BigDecimal
      column :number5, BigDecimal, size: 10
      column :number6, BigDecimal, size: [10,2]
      column :number7, Numeric

      column :date1, Date
      column :date2, DateTime

      column :time1, Time
      column :time2, Time, only_time: true

      column :boolean1, TrueClass
      column :boolean2, FalseClass
    end
  end
end

require 'test_helper'

describe Lotus::Model::Configuration do
  let(:configuration) { Lotus::Model::Configuration.new }

  describe '.for' do
    before do
      Lotus::Model.configure do
        adapter type: :memory, uri: 'memory://localhost'
      end

      module Lotus
        class Zen
        end
      end

      class Zen
        Model = ::Lotus::Model.duplicate(self) {}
        class Sencha; end
      end
    end

    after do
      Object.send(:remove_const, :Zen)
    end

    describe 'when base class has Lotus namespace' do
      it 'returns duplicated configuration of Lotus::Model' do
        Lotus::Model::Configuration.for(Lotus::Zen).must_equal Lotus::Model.configuration
      end
    end

    describe 'when base class has namespace' do
      it 'returns duplicated configuration of {namespace}::Model' do
        Lotus::Model::Configuration.for(Zen::Sencha).must_equal Zen::Model.configuration
      end
    end
  end

  describe '#adapter_config' do
    it 'defaults to an empty set' do
      configuration.adapter_config.must_be_nil
      configuration.instance_variable_get(:@adapter).must_be_nil
    end

    it 'allows to register adapter configuration' do
      configuration.adapter(type: :sql, uri: SQLITE_CONNECTION_STRING)

      adapter_config = configuration.adapter_config
      adapter_config.must_be_instance_of Lotus::Model::Config::Adapter
      adapter_config.uri.must_equal SQLITE_CONNECTION_STRING
    end

    if Lotus::Utils.jruby?
      it 'avoids duplication' do
        configuration.adapter(type: :sql,    uri: 'jdbc:sqlite:uri')
        configuration.adapter(type: :memory, uri: 'memory://uri')

        configuration.adapter_config.type.must_equal :sql
      end
    else
      it 'avoids duplication' do
        configuration.adapter(type: :sql,    uri: 'sqlite3://uri')
        configuration.adapter(type: :memory, uri: 'memory://uri')

        configuration.adapter_config.type.must_equal :sql
      end
    end

    it 'raises error when :type is omitted' do
      exception = -> { configuration.adapter(uri: SQLITE_CONNECTION_STRING) }.must_raise(ArgumentError)
      exception.message.must_equal 'missing keyword: type'
    end

    it 'raises error when :uri is omitted' do
      exception = -> { configuration.adapter(type: :memory) }.must_raise(ArgumentError)
      exception.message.must_equal 'missing keyword: uri'
    end
  end

  describe '#load!' do
    before do
      configuration.mapping do
        collection :users do
          entity User

          attribute :id, Integer
          attribute :name, String
        end
      end
    end

    it 'instantiates the registered adapter (memory)' do
      configuration.adapter(type: :memory, uri: 'memory://localhost')
      configuration.load!

      adapter = configuration.instance_variable_get(:@adapter)
      adapter.must_be_instance_of Lotus::Model::Adapters::MemoryAdapter
    end

    it 'instantiates the registered adapter (file system)' do
      configuration.adapter(type: :file_system, uri: FILE_SYSTEM_CONNECTION_STRING)
      configuration.load!

      adapter = configuration.instance_variable_get(:@adapter)
      adapter.must_be_instance_of Lotus::Model::Adapters::FileSystemAdapter
    end

    it 'instantiates the registered adapter (sql)' do
      configuration.adapter(type: :sql, uri: SQLITE_CONNECTION_STRING)
      configuration.load!

      adapter = configuration.instance_variable_get(:@adapter)
      adapter.must_be_instance_of Lotus::Model::Adapters::SqlAdapter
    end

    it 'builds collections from mapping' do
      configuration.adapter(type: :memory, uri: 'memory://localhost')
      configuration.load!

      collection = configuration.mapper.collection(:users)
      collection.must_be_kind_of Lotus::Model::Mapping::Collection
      collection.name.must_equal :users
    end
  end

  describe '#mapping' do
    describe "when a block is given" do
      it 'configures the global persistence mapper through block' do
        configuration.mapping do
          collection :users do
            entity User

            attribute :id, Integer
            attribute :name, String
          end
        end

        mapper_config = configuration.instance_variable_get(:@mapper_config)
        mapper_config.must_be_instance_of Lotus::Model::Config::Mapper
      end
    end

    describe "when a path is given" do
      it 'configures the global persistence mapper through block' do
        configuration.mapping 'test/fixtures/mapping'

        mapper_config = configuration.instance_variable_get(:@mapper_config)
        mapper_config.must_be_instance_of Lotus::Model::Config::Mapper
      end
    end

    describe "when block and path are not given" do
      it 'raise error' do
        exception = -> { configuration.mapping }.must_raise Lotus::Model::InvalidMappingError
        exception.message.must_equal 'You must specify a block or a file.'
      end
    end
  end

  describe '#logger' do
    describe "when a logger is not set" do
      it 'default to stdlib logger' do
        configuration.logger.must_be_instance_of ::Logger
      end
    end

    describe "when a logger instance is given" do
      before do
        class CustomLogger < ::Logger
        end
      end

      after do
        Object.send(:remove_const, :CustomLogger)
      end

      it 'sets the logger for configuration' do
        configuration.logger(CustomLogger.new(STDERR)).must_be_instance_of CustomLogger
        configuration.logger.must_be_instance_of CustomLogger
      end
    end
  end

  describe '#migrations_directory' do
    describe "when no migration directory has been pre-configured before" do
      it 'returns default directory' do
        configuration.reset!
        configuration.migrations_directory.must_equal configuration.send(:_default_migrations_directory)
      end
    end

    describe "when migration directory is provided" do
      it 'returns default directory' do
        directory = 'custom/db/migrations'
        configuration.migrations_directory directory
        configuration.migrations_directory.must_equal directory
      end
    end
  end

  describe '#reset!' do
    before do
      configuration.adapter(type: :sql, uri: SQLITE_CONNECTION_STRING)
      configuration.mapping do
        collection :users do
          entity User

          attribute :id, Integer
          attribute :name, String
        end
      end

      configuration.load!
      configuration.reset!
    end

    it 'resets adapter' do
      configuration.adapter_config.must_be_nil
      configuration.instance_variable_get(:@adapter).must_be_nil
    end

    it 'resets mapper' do
      configuration.instance_variable_get(:@mapper_config).must_be_nil
      configuration.mapper.must_be_instance_of Lotus::Model::NullMapper
    end
  end
end

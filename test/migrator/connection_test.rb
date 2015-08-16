require 'test_helper'
require 'lotus/model/migrator/connection'

describe Lotus::Model::Migrator::Connection do
  let(:connection) { Lotus::Model::Migrator::Connection.new(adapter_connection) }

  let(:adapter_connection) do
    OpenStruct.new(
      uri: 'postgresql://postgres:s3cr3T@127.0.0.1:5432/database',
      opts: { user: 'postgres', password: 's3cr3T' }
    )
  end

  describe '#jdbc?' do
    it 'returns false' do
      connection.jdbc?.must_equal false
    end
  end

  describe '#global_uri' do
    it 'returns connection URI without database' do
      connection.global_uri.scan('database').empty?.must_equal true
    end
  end

  describe '#parsed_uri?' do
    it 'returns an URI instance' do
      connection.parsed_uri.must_be_kind_of URI
    end
  end

  describe '#user' do
    it 'returns configured user' do
      connection.user.wont_equal nil
      connection.user.must_equal 'postgres'
    end
  end

  describe '#password' do
    it 'returns configured password' do
      connection.password.wont_equal nil
      connection.password.must_equal 's3cr3T'
    end
  end

  describe 'when jdbc connection' do
    let(:adapter_connection) do
      OpenStruct.new(
        uri: 'jdbc:postgresql://127.0.0.1:5432/database?user=postgres&password=s3cr3T',
        opts: {}
      )
    end

    describe '#jdbc?' do
      it 'returns true' do
        connection.jdbc?.must_equal true
      end
    end

    describe '#host' do
      it 'returns configured host' do
        connection.host.wont_equal nil
        connection.host.must_equal '127.0.0.1'
      end
    end

    describe '#port' do
      it 'returns configured port' do
        connection.port.wont_equal nil
        connection.port.must_equal 5432
      end
    end

    describe '#user' do
      it 'returns configured user' do
        connection.user.wont_equal nil
        connection.user.must_equal 'postgres'
      end

      describe 'when there is no user option' do
        let(:adapter_connection) do
          OpenStruct.new(uri: 'jdbc:postgresql://127.0.0.1/database', opts: {})
        end

        it 'returns nil' do
          connection.user.must_equal nil
        end
      end
    end

    describe '#password' do
      it 'returns configured password' do
        connection.password.wont_equal nil
        connection.password.must_equal 's3cr3T'
      end

      describe 'when there is no password option' do
        let(:adapter_connection) do
          OpenStruct.new(uri: 'jdbc:postgresql://127.0.0.1/database', opts: {})
        end

        it 'returns nil' do
          connection.password.must_equal nil
        end
      end
    end

    describe '#database' do
      it 'returns configured database' do
        connection.database.wont_equal nil
        connection.database.must_equal 'database'
      end
    end
  end
end

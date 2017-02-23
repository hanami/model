require 'test_helper'
require 'hanami/model/migrator/connection'

describe Hanami::Model::Migrator::Connection do
  let(:connection) { Hanami::Model::Migrator::Connection.new(hanami_model_configuration) }

  describe 'when not a jdbc connection' do
    let(:hanami_model_configuration) do
      OpenStruct.new(
        url: 'postgresql://postgres:s3cr3T@127.0.0.1:5432/database'
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

    describe '#host' do
      it 'returns configured host' do
        connection.host.must_equal '127.0.0.1'
      end
    end

    describe '#port' do
      it 'returns configured port' do
        connection.port.must_equal 5432
      end
    end

    describe '#database' do
      it 'returns configured database' do
        connection.database.must_equal 'database'
      end
    end

    describe '#user' do
      it 'returns configured user' do
        connection.user.must_equal 'postgres'
      end

      describe 'when there is no user option' do
        let(:hanami_model_configuration) do
          OpenStruct.new(url: 'postgresql://127.0.0.1:5432/database')
        end

        it 'returns nil' do
          connection.user.must_equal nil
        end
      end
    end

    describe '#password' do
      it 'returns configured password' do
        connection.password.must_equal 's3cr3T'
      end

      describe 'when there is no password option' do
        let(:hanami_model_configuration) do
          OpenStruct.new(url: 'postgresql://127.0.0.1/database')
        end

        it 'returns nil' do
          connection.password.must_equal nil
        end
      end
    end
  end

  describe 'when jdbc connection' do
    let(:hanami_model_configuration) do
      OpenStruct.new(
        url: 'jdbc:postgresql://127.0.0.1:5432/database?user=postgres&password=s3cr3T'
      )
    end

    describe '#jdbc?' do
      it 'returns true' do
        connection.jdbc?.must_equal true
      end
    end

    describe '#host' do
      it 'returns configured host' do
        connection.host.must_equal '127.0.0.1'
      end
    end

    describe '#port' do
      it 'returns configured port' do
        connection.port.must_equal 5432
      end
    end

    describe '#user' do
      it 'returns configured user' do
        connection.user.must_equal 'postgres'
      end

      describe 'when there is no user option' do
        let(:hanami_model_configuration) do
          OpenStruct.new(url: 'jdbc:postgresql://127.0.0.1/database')
        end

        it 'returns nil' do
          connection.user.must_equal nil
        end
      end
    end

    describe '#password' do
      it 'returns configured password' do
        connection.password.must_equal 's3cr3T'
      end

      describe 'when there is no password option' do
        let(:hanami_model_configuration) do
          OpenStruct.new(url: 'jdbc:postgresql://127.0.0.1/database')
        end

        it 'returns nil' do
          connection.password.must_equal nil
        end
      end
    end

    describe '#database' do
      it 'returns configured database' do
        connection.database.must_equal 'database'
      end
    end
  end
end

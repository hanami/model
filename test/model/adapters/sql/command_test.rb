require 'test_helper'

describe Lotus::Model::Adapters::Sql::Command do
  let(:collection) { Object.new }
  let(:query) do
    query = Object.new
    query.instance_variable_set(:@collection, collection)
    query.define_singleton_method(:scoped, -> { @collection })
    query
  end

  before do
    @command = Lotus::Model::Adapters::Sql::Command.new(query)
  end

  describe '#create' do
    it 'rescues database errors' do
      method_called = false
      @command.stub(:_rescue_database_error, -> { method_called = true }) do
        collection.define_singleton_method(:insert) { |_| }
        @command.create(Object.new)
      end
      method_called.must_equal true
    end
  end

  describe '#update' do
    it 'rescues database errors' do
      method_called = false
      @command.stub(:_rescue_database_error, -> { method_called = true }) do
        collection.define_singleton_method(:update) { |_| }
        @command.update(Object.new)
      end
      method_called.must_equal true
    end
  end

  describe '#delete' do
    it 'rescues database errors' do
      method_called = false
      @command.stub(:_rescue_database_error, -> { method_called = true }) do
        collection.define_singleton_method(:delete) {}
        @command.delete
      end
      method_called.must_equal true
    end
  end

  describe '#_rescue_database_error' do
    it 'yields' do
      block_called = false
      @command.send(:_rescue_database_error) { block_called = true }
      block_called.must_equal true
    end

    describe 'when a Sequel::DatabaseError is raised' do
      describe 'when the error is Sequel::CheckConstraintViolation' do
        it 'raises the corresponding lotus error' do
          error = Sequel::CheckConstraintViolation.new
          -> { @command.send(:_rescue_database_error) { raise error } }
            .must_raise(Lotus::Model::CheckConstraintViolationError)
        end
      end

      describe 'when the error is Sequel::ForeignKeyConstraintViolation' do
        it 'raises the corresponding lotus error' do
          error = Sequel::ForeignKeyConstraintViolation.new
          -> { @command.send(:_rescue_database_error) { raise error } }
            .must_raise(Lotus::Model::ForeignKeyConstraintViolationError)
        end
      end

      describe 'when the error is Sequel::NotNullConstraintViolation' do
        it 'raises the corresponding lotus error' do
          error = Sequel::NotNullConstraintViolation.new
          -> { @command.send(:_rescue_database_error) { raise error } }
            .must_raise(Lotus::Model::NotNullConstraintViolationError)
        end
      end

      describe 'when the error is Sequel::UniqueConstraintViolation' do
        it 'raises the corresponding lotus error' do
          error = Sequel::UniqueConstraintViolation.new
          -> { @command.send(:_rescue_database_error) { raise error } }
            .must_raise(Lotus::Model::UniqueConstraintViolationError)
        end
      end

      describe 'when the specific error is not handled' do
        it 'raises a lotus invalid command error' do
          error = Sequel::DatabaseError.new('foo')
          -> { @command.send(:_rescue_database_error) { raise error } }
            .must_raise(Lotus::Model::InvalidCommandError)
        end
      end
    end

    describe 'when a different error is raised' do
      it 'bubbles the error up' do
        error = Sequel::Error.new
        -> { @command.send(:_rescue_database_error) { raise error } }
          .must_raise(Sequel::Error)
      end
    end
  end
end

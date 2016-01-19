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
    describe 'when a Sequel::ForeignKeyConstraintViolation is raised' do
      it 'raises Lotus::Model::Error exception' do
        collection.define_singleton_method(:insert) do |_|
          raise ::Sequel::ForeignKeyConstraintViolation.new('fkey constraint error')
        end
        exception = -> { @command.create(Object.new) }.must_raise(Lotus::Model::Error)
        exception.message.must_equal('fkey constraint error')
      end
    end

    describe 'when a Sequel::CheckConstraintViolation is raised' do
      it 'raises Lotus::Model::Error exception' do
        collection.define_singleton_method(:insert) do |_|
          raise ::Sequel::CheckConstraintViolation.new('check constraint error')
        end
        exception = -> { @command.create(Object.new) }.must_raise(Lotus::Model::Error)
        exception.message.must_equal('check constraint error')
      end
    end

    describe 'when a Sequel::NotNullConstraintViolation is raised' do
      it 'raises Lotus::Model::Error exception' do
        collection.define_singleton_method(:insert) do |_|
          raise ::Sequel::NotNullConstraintViolation.new('not null constraint error')
        end
        exception = -> { @command.create(Object.new) }.must_raise(Lotus::Model::Error)
        exception.message.must_equal('not null constraint error')
      end
    end

    describe 'when a Sequel::UniqueConstraintViolation is raised' do
      it 'raises Lotus::Model::Error exception' do
        collection.define_singleton_method(:insert) do |_|
          raise ::Sequel::UniqueConstraintViolation.new('unique constraint error')
        end
        exception = -> { @command.create(Object.new) }.must_raise(Lotus::Model::Error)
        exception.message.must_equal('unique constraint error')
      end
    end

    describe 'when a Sequel::DatabaseError is raised' do
      it 'raises Lotus::Model::Error exception' do
        collection.define_singleton_method(:insert) do |_|
          raise ::Sequel::DatabaseError.new('db error')
        end
        exception = -> { @command.create(Object.new) }.must_raise(Lotus::Model::Error)
        exception.message.must_equal('db error')
      end
    end

    describe 'when an error that is not inherited from Sequel::DatabaseError is raised' do
      it 'bubbles the error up' do
        collection.define_singleton_method(:insert) do |_|
          raise Sequel::Error.new('constraint error')
        end
        exception = -> { @command.create(Object.new) }.must_raise(Sequel::Error)
        exception.message.must_equal('constraint error')
      end
    end
  end

  describe '#update' do
    describe 'when a Sequel::DatabaseError is raised' do
      it 'raises Lotus::Model::Error exception' do
        collection.define_singleton_method(:update) do |_|
          raise Sequel::DatabaseError.new('db error')
        end
        exception = -> { @command.update(Object.new) }.must_raise(Lotus::Model::Error)
        exception.message.must_equal('db error')
      end
    end

    describe 'when a different error is raised' do
      it 'bubbles the error up' do
        collection.define_singleton_method(:update) do |_|
          raise Sequel::Error.new('constraint error')
        end
        exception = -> { @command.update(Object.new) }.must_raise(Sequel::Error)
        exception.message.must_equal('constraint error')
      end
    end
  end

  describe '#delete' do
    describe 'when a Sequel::DatabaseError is raised' do
      it 'raises Lotus::Model::Error exception' do
        collection.define_singleton_method(:delete) do
          raise Sequel::DatabaseError.new('db error')
        end
        exception = -> { @command.delete }.must_raise(Lotus::Model::Error)
        exception.message.must_equal('db error')
      end
    end

    describe 'when a different error is raised' do
      it 'bubbles the error up' do
        collection.define_singleton_method(:delete) do
          raise Sequel::Error.new('constraint error')
        end
        exception = -> { @command.delete }.must_raise(Sequel::Error)
        exception.message.must_equal('constraint error')
      end
    end
  end
end

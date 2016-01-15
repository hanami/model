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
    describe 'when a Sequel::DatabaseError is raised' do
      it 'raises a lotus error' do
        collection.define_singleton_method(:insert) do |_|
          raise Sequel::DatabaseError.new
        end
        -> { @command.create(Object.new) }.must_raise(Lotus::Model::Error)
      end
    end

    describe 'when a different error is raised' do
      it 'bubbles the error up' do
        collection.define_singleton_method(:insert) do |_|
          raise Sequel::Error.new
        end
        -> { @command.create(Object.new) }.must_raise(Sequel::Error)
      end
    end
  end

  describe '#update' do
    describe 'when a Sequel::DatabaseError is raised' do
      it 'raises a lotus error' do
        collection.define_singleton_method(:update) do |_|
          raise Sequel::DatabaseError.new
        end
        -> { @command.update(Object.new) }.must_raise(Lotus::Model::Error)
      end
    end

    describe 'when a different error is raised' do
      it 'bubbles the error up' do
        collection.define_singleton_method(:update) do |_|
          raise Sequel::Error.new
        end
        -> { @command.update(Object.new) }.must_raise(Sequel::Error)
      end
    end
  end

  describe '#delete' do
    describe 'when a Sequel::DatabaseError is raised' do
      it 'raises a lotus error' do
        collection.define_singleton_method(:delete) do
          raise Sequel::DatabaseError.new
        end
        -> { @command.delete }.must_raise(Lotus::Model::Error)
      end
    end

    describe 'when a different error is raised' do
      it 'bubbles the error up' do
        collection.define_singleton_method(:delete) do
          raise Sequel::Error.new
        end
        -> { @command.delete }.must_raise(Sequel::Error)
      end
    end
  end
end

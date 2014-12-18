require 'test_helper'

describe Lotus::Model::Config::Mapper do
  describe '#initialize' do
    describe 'when no block or file path is given' do
      it 'raises error' do
        exception = -> { Lotus::Model::Config::Mapper.new }.must_raise Lotus::Model::InvalidMappingError
        exception.message.must_equal 'You must specify a block or a file.'
      end
    end

    describe "when a block is given" do
      it 'converts block to proc and save in an instance' do
        config = Lotus::Model::Config::Mapper.new do
          collection :users do
            entity User

            attribute :id, Integer
            attribute :name, String
          end
        end

        assert config.instance_variable_get(:@blk).is_a?(Proc)
      end
    end

    describe "when a path is given" do
      it 'stores the path to mapping file' do
        config = Lotus::Model::Config::Mapper.new('test/fixtures/mapping')
        config.instance_variable_get(:@path).must_equal Pathname.new("#{Dir.pwd}/test/fixtures/mapping")
      end
    end
  end

  describe '#to_proc' do
    describe 'when block is given' do
      it 'returns the proc of the block' do
        config = Lotus::Model::Config::Mapper.new do
          collection :users do
            entity User

            attribute :id, Integer
            attribute :name, String
          end
        end

        assert config.to_proc.is_a?(Proc)
      end
    end

    describe 'when a file is given' do
      it 'reads the content of the file and return a proc of content' do
        config = Lotus::Model::Config::Mapper.new('test/fixtures/mapping')

        assert config.to_proc.is_a?(Proc)
      end
    end

    describe 'when an invalid file is given' do
      it 'raises error' do
        exception = -> { Lotus::Model::Config::Mapper.new('test/fixtures/invalid').to_proc }.must_raise ArgumentError
        exception.message.must_equal 'You must specify a valid filepath.'
      end
    end
  end
end
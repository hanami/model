require 'rom-sql'

module Hanami
  module Model
    module Sql
    end
  end
end

Sequel.default_timezone = :utc

ROM.plugins do
  adapter :sql do
    register :mapping,    Hanami::Model::Plugins::Mapping,    type: :command
    register :timestamps, Hanami::Model::Plugins::Timestamps, type: :command
  end
end

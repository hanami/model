require 'hanami/model/associations/has_many'

module Hanami
  module Model
    class Association
      def self.new(repository, target, subject)
        case repository.root.associations[target]
        when ROM::SQL::Association::OneToMany then Associations::HasMany
        else
          raise 'unsupported association'
        end.new(repository, repository.root.name.to_sym, target, subject)
      end
    end
  end
end

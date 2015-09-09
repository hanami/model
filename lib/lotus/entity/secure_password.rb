require 'lotus/validations'

module Lotus
  module Entity
    module SecurePassword
      # Maximum as permitted by bcrypt's hash function
      MAX_LENGTH = 72

      def self.included(base)
        base.class_eval do
          begin
            require 'bcrypt'
          rescue LoadError
            STDERR.puts 'Add bcrypt to your Gemfile and `bundle install`'
            raise
          end

          include Lotus::Validations
          attribute :password, confirmation: true, size: 0..MAX_LENGTH
          attribute :password_digest

          def password=(unencrypted)
            if unencrypted.nil?
              @attributes.set(:password_digest, nil)
            elsif !unencrypted.empty?
              encrypted = BCrypt::Password.create(unencrypted)
              @attributes.set(:password_digest, encrypted)
              @attributes.set(:password, unencrypted)
            end
          end

          def authenticate(unencrypted)
            BCrypt::Password.new(password_digest).is_password?(unencrypted) && self
          end
        end
      end
    end
  end
end

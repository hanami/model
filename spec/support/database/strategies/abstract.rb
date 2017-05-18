module Database
  module Strategies
    class Abstract
      def self.eligible?(_adapter)
        false
      end

      def run
        before
        load_dependencies
        export_env
        create_database
        configure
        after
        sleep 1
      end

      protected

      def before
        # Optional hook for subclasses
      end

      def database_name
        'hanami_model'
      end

      def load_dependencies
        raise NotImplementedError
      end

      def export_env
        ENV['HANAMI_DATABASE_NAME'] = database_name
      end

      def create_database
        raise NotImplementedError
      end

      def configure
        returing = Hanami::Model.configure do
          adapter ENV['HANAMI_DATABASE_ADAPTER'].to_sym, ENV['HANAMI_DATABASE_URL']
        end

        returing == Hanami::Model or raise 'Hanami::Model.configure should return Hanami::Model'
      end

      def after
        # Optional hook for subclasses
      end

      private

      def jruby?
        Platform::Engine.engine?(:jruby)
      end

      def ci?
        Platform.ci?
      end
    end
  end
end

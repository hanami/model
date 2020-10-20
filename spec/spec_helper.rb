$LOAD_PATH.unshift "lib"
require "hanami/devtools/unit"
require "hanami/model"

require_relative "./support/rspec"
require_relative "./support/test_io"
require_relative "./support/platform"
require_relative "./support/database"
require_relative "./support/fixtures"

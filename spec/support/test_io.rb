module TestIO
  def self.with_stdout
    stdout = $stdout
    $stdout = stream
    yield
  ensure
    $stdout.close
    $stdout = stdout
  end

  def self.stream
    File.new(ENV["HANAMI_DATABASE_LOGGER"], "a+")
  end
end

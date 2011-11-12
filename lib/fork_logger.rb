require 'logger'

class ForkLogger
  def initialize
    @loggers = []
    FileUtils.mkdir_p('logs')
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    @loggers << Logger.new("logs/#{timestamp}.log")
    @loggers << Logger.new(STDOUT)
  end
  
  def puts message
    @loggers.each do |logger|
      logger.info message
    end
  end
  
  def method_missing method, message
    @loggers.each do |logger|
      logger.send(method, message)
    end
  end
end
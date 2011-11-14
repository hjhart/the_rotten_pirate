require 'logger'

class ForkLogger
  def initialize
    @loggers = []
    FileUtils.mkdir_p('logs')
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    @loggers << Logger.new("logs/#{timestamp}.log")
    @loggers << Logger.new(STDOUT)
    @prowl
  end
  
  def prowl_message event, description
    require 'prowl'
    
    prowl_config_file = File.join 'config', 'prowl.yml'
    if File.exists? prowl_config_file
      prowl_config = YAML.load File.open(prowl_config_file).read
      if prowl_config["active"]
        Prowl.add(
          :apikey => prowl_config["api_key"],
          :application => "The Rotten Pirate",
          :event => event,
          :description => description
        )
      end
    end
    puts "Prowl notification sent '#{event}'"
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
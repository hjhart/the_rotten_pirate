require 'yaml'

class YAMLWriter
  def initialize object
    @yaml = object.to_yaml
  end
  
  def write
    FileUtils.mkdir_p('logs')
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    filename = "logs/#{timestamp}_results.yaml"
    File.open(filename, 'w') { |f| f.puts @yaml }
  end
end
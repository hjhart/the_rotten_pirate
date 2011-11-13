require 'json'

class JSONWriter
  def initialize object
    @json = object.to_json
  end
  
  def write
    FileUtils.mkdir_p('logs')
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    filename = "logs/#{timestamp}_results.json"
    File.open(filename, 'w') { |f| f.puts @json }
  end
end
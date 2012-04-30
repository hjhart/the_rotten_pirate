module MWhich
  class Client

    VALID_SERVICES = [:amazon,:hulu,:itunes,:netflix]
    SERVICE_MAP = {
      :amazon => MWhich::Services::Amazon,
      :hulu => MWhich::Services::Hulu,
      :itunes => MWhich::Services::ITunes,
      :netflix => MWhich::Services::Netflix
    }
    IGNORE_MEDIA = [:clips, :trailers]

    attr_accessor :services, :ignore

    # Arguments (all are optional):
    # - :services        - One or more of :amazon, :netflix, :hulu, or :itunes. Default is :all
    def initialize(options={})
      self.services = options[:services] || VALID_SERVICES
      self.ignore = options[:ignore] ? IGNORE_MEDIA & options[:ignore] : IGNORE_MEDIA
    end

    # Search for a movie/tv show by title
    def search(title)
      results = {}
      self.services.each do |service|
        s = SERVICE_MAP[service].new(:ignore => ignore)
        results[service] = s.search(title)
      end

      results
    end
  end
end
module MWhich
  module Services
    class ITunes
      def initialize(options={})
        @endpoint = "http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStoreServices.woa/wa/wsSearch"
      end

      def search(title)
        results = request(title)

        titles = []
        results.each do |result|
          titles << "#{result['kind']}: #{result['trackName']} ($#{result['trackPrice']})"
        end

        titles
      end

      protected

        def request(title)
          # We'll do searches across both TV and movies and merge the results
          results = []
          ['tvShow', 'movie'].each do |type|
            url = "#{@endpoint}?term=#{URI::escape(title)}&media=#{type}"
            response = Net::HTTP.get_response(URI.parse(url))
            data = Yajl::Parser.parse(response.body)
            results |= data['results']
          end

          results
        end

    end
  end
end

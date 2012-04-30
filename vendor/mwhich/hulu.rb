module MWhich
  module Services
    class Hulu
      def initialize(options={})
        @endpoint_url = "http://m.hulu.com"
        @ignore_media = []
        if options[:ignore]
          @ignore_media << 'film_trailer' if options[:ignore].include?:trailers
          @ignore_media << 'clip' if options[:ignore].include?:clips
        end
      end

      def search(title)
        results = request(title)

        titles = []
        results.xpath("//video").each do |result|
          next if @ignore_media.include?result.css('video-type').inner_html
          append = ""
          if (ishulu = result.css('is-hulu'))
            append = " - Not on hulu!" if ishulu.inner_html == "0"
          end
          titles << "#{result.css('video-type').inner_html}: #{result.css('title').inner_html}#{append}"
        end

        titles
      end

      protected

        def request(title)
          url = "#{@endpoint_url}/search?dp_identifier=hulu&query=#{URI::escape(title)}&items_per_page=10&page=1"

          response = Net::HTTP.get_response(URI.parse(url))
          Nokogiri::XML(response.body)
        end
    end
  end
end
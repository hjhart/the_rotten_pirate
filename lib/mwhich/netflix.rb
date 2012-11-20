module MWhich
  module Services
    class Netflix

      def initialize(options={})
        @endpoint = "http://odata.netflix.com/v1/Catalog/"
        @format = "json"
      end

      def search(title)
        results = request(title)

        titles = []
        results['d']['results'].each do |result|
          titles << "#{result['Type']}: #{result['Name']}#{result['Instant']['Available'] ? ' - Watch now!' : ''}"
        end

        titles
      end

      protected

        def request(title)
          filter = "Name eq '#{title}'"
          url = "#{@endpoint}Titles?$filter=#{URI::escape(filter)}&$format=#{@format}"

          response = Net::HTTP.get_response(URI.parse(url))
          Yajl::Parser.parse(response.body)
        end

    end
  end
end
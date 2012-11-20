module MWhich
  module Services
    class Amazon
      def initialize(options={})
        @endpoint_url = "http://webservices.amazon.com/onca/xml"
        @aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
        @aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
      end

      def search(title)
        results = request(title)

        titles = []
        results.css("Item").each do |result|
          titles << "#{result.css('ProductGroup').inner_html}: #{result.css('Title').inner_html}"
        end

        titles
      end

      protected

        def request(title)
          params = {
            "Operation" => "ItemSearch",
            "Service" => "AWSECommerceService",
            "AWSAccessKeyId" => @aws_access_key_id,
            "SearchIndex" => "UnboxVideo",
            "Keywords" => URI::escape(title),
            "Timestamp" => Time.now.utc.iso8601 #'2010-11-29T06:53:00Z' # Time.now.iso8601
          }
          sorted_params = params.sort_by{|x,y| x}.map{|x,y| "#{x}=#{CGI::escape(y)}"}.join('&')
          signature = sign("GET\nwebservices.amazon.com\n/onca/xml\n#{sorted_params}").strip
          url = "#{@endpoint_url}?#{sorted_params}&Signature=#{CGI::escape(signature)}"

          response = Net::HTTP.get_response(URI.parse(url))
          Nokogiri::XML(response.body)
        end

        def sign(string)
          hmac = HMAC::SHA256.new(@aws_secret_access_key)
          hmac.update(string)
          Base64.encode64(hmac.digest).chomp
        end
    end
  end
end
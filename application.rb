$:.push 'lib'
require 'the_rotten_pirate'
require 'json'

class Application < Sinatra::Base
  enable :sessions
  set :root, File.dirname(__FILE__)
  set :logging, true

  get '/' do
    @message = session[:message]
    erb :index
  end

  get '/check' do
    require 'vendor/mwhich'
    movie = params[:movie]
    m = MWhich::Client.new(:services => [:hulu, :itunes, :netflix])
    @results = m.search(movie)
    erb :check
  end
  
  post '/download' do
    movie = params[:movie]

    if movie.nil? || movie.strip.empty?
      session[:error] = 'You must enter a title to download'
      redirect '/' 
    else
      torrent_url = TheRottenPirate.new.initialize_download movie
      torrent_url_match = torrent_url.match(/http:\/\/torrents.thepiratebay.se\/\d+\/(.*)/)
      if(torrent_url_match)
        torrent_name = torrent_url_match[1]
        session[:message] = "Download Started (filename is #{torrent_name})"
      else
        session[:message] = "Download Started (filename unknown)"
      end
      
      redirect '/'
    end
  end
  
  get '/recent' do
    config = YAML.load(File.open('config/config.yml').read)
    @movies = Download.all.map { |d| d[:name] }.pop 12

    begin

      @movies.map! do |movie_name|
        if Download.has_youtube_url? movie_name
          movie = Download.find_by_name(movie_name).first
          trailer_url = movie[:youtube_url]
          thumbnail_url = movie[:thumbnail_url]
          {
            :name => movie_name,
            :youtube_url => trailer_url,
            :thumbnail_url => thumbnail_url
          }
        else
          require 'youtube_it'
          begin
            client = YouTubeIt::Client.new(:dev_key => config["youtube_api_key"])

            video_results = client.videos_by(:query => "#{movie_name} trailer")
            youtube_video = video_results.videos.first
            trailer_url = youtube_video.media_content.first.url
            thumbnail_url = youtube_video.thumbnails[1].url
            Download.add_youtube_url(movie_name,  trailer_url, thumbnail_url)
          rescue REXML::ParseException
            trailer_url = "http://www.crayons.com"
            thumbnail_url = "undefined"
            session[:error] = 'Obtaining content from youtube failed. Check your internet connection.'
          end
          {
            :name => movie_name,
            :youtube_url => trailer_url,
            :thumbnail_url => thumbnail_url
          }

        end

      end
      ap @movies
    rescue OpenURI::HTTPError
      
      return "You must sign up for an API key from youtube and put it in your config file before using this page."
    end
    erb :recent
  end
end

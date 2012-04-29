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
    youtube_api_key = config["youtube_api_key"]
    @movies = Download.all.map { |d| d[:name] }.pop 12
    require 'youtube_it'
    
    begin
      client = YouTubeIt::Client.new(:dev_key => config["youtube_api_key"])
      @movies.map! do |movie_name| 
        video_results = client.videos_by(:query => "#{movie_name} trailer")
        trailer_url = video_results.videos.first.media_content.first.url
        thumbnail_url = video_results.videos.first.thumbnails[1].url
        {
          :name => movie_name, 
          :youtube_url => trailer_url,
          :thumbnail_url => thumbnail_url
        } 
      end
    rescue OpenURI::HTTPError
      
      return "You must sign up for an API key from youtube and put it in your config file before using this page."
    end
    erb :recent
  end
end

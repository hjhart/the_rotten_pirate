class DownloadsController < ApplicationController
  # GET /downloads
  # GET /downloads.json
  def index
    @downloads = Download.all(:limit => 24, :order => "created_at desc", :conditions => "download_url is not null")

    get_youtube_information
    replace_with_mobile_links_if_ios

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @downloads }
    end
  end

  # GET /downloads/1
  # GET /downloads/1.json
  def show
    @download = Download.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @download }
    end
  end

  # GET /downloads/new
  # GET /downloads/new.json
  def new
    @download = Download.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @download }
    end
  end

  # GET /downloads/1/edit
  def edit
    @download = Download.find(params[:id])
  end

  # POST /downloads
  # POST /downloads.json
  def create
    @download = Download.new(params[:download])
    @pirate = Pirate.new

    respond_to do |format|
      if @download.save
        ap @pirate.initialize_download(@download.id)
        format.html { redirect_to @download, notice: 'Download was successfully created. Try refreshing to see the torrent name.' }
        format.json { render json: @download, status: :created, location: @download }
      else
        format.html { render action: "new" }
        format.json { render json: @download.errors, status: :unprocessable_entity }
      end
    end
  end

# PUT /downloads/1
# PUT /downloads/1.json
  def update
    @download = Download.find(params[:id])

    respond_to do |format|
      if @download.update_attributes(params[:download])
        format.html { redirect_to @download, notice: 'Download was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @download.errors, status: :unprocessable_entity }
      end
    end
  end

# DELETE /downloads/1
# DELETE /downloads/1.json
  def destroy
    @download = Download.find(params[:id])
    @download.destroy

    respond_to do |format|
      format.html { redirect_to downloads_url }
      format.json { head :no_content }
    end
  end

  def check
    # This is broken currently.
    require 'mwhich'
    movie = params[:movie]
    m = MWhich::Client.new(:services => [:hulu, :itunes, :netflix])
    @results = m.search(movie)
  end

  protected
  def get_youtube_information
    config = YAML.load(File.open('config/config.yml').read)
    begin
      @downloads.each do |movie|
        unless movie.has_youtube_url?
          begin
            client = YouTubeIt::Client.new(:dev_key => config["youtube_api_key"])

            video_results = client.videos_by(:query => "#{movie.name} trailer")
            youtube_video = video_results.videos.first
            if(youtube_video)
              trailer_url = youtube_video.media_content.first.url
              thumbnail_url = youtube_video.thumbnails[1].url
              movie.update_attributes(:youtube_url => trailer_url, :thumbnail_url => thumbnail_url)
            end
          rescue REXML::ParseException
            trailer_url = "http://www.crayons.com"
            thumbnail_url = "undefined"
            session[:error] = 'Obtaining content from youtube failed. Check your internet connection.'
          end
        end
      end
    rescue OpenURI::HTTPError
      return "You must sign up for an API key from youtube and put it in your config file before using this page."
    end
  end

  def replace_with_mobile_links_if_ios
    mobile_user_agent ||= ( request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)|(AppleWebKit\/.+Mobile)/] )
    if mobile_user_agent
      @downloads.each do |download|
        download[:youtube_url].gsub!(/\?version.*/, '')
      end
    end
  end
end

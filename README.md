# The Rotten Pirate! 
(or: "STOP STEALING MY MOVIES YA DAMN KIDS!")

### Quick 'n' dirty

 - Fetches the [Rotten Tomatoes New DVDs feed](http://www.rottentomatoes.com/syndication/tab/new_releases.txt)
 - Filters the DVDs with *configurable* criterion
   - Only "Certified Fresh" movies
   - Only movies whose "TomatoMeter Percent" is greater than XX%
   - Movies not already downloaded through TRP
 - We then pass the movies to the [torrent_api](https://github.com/hjhart/torrent_api) gem.
   - The gem looks at comments left by users for ratings of audio and video
   - Performs an average of all ratings given
   - Selects the highest scoring torrent and
 - Then it downloads the appropriate torrents to your configured directory
   - If you set this directory up to be "watched" by your torrent program these will start automatically!

Pretty neat, yeah?

### Setup

Clone the source and install proper gems

	git clone git@github.com:hjhart/the_rotten_pirate.git
	cd the_rotten_pirate
	
At this point if RVM is installed you'll get prompted to trust this new .rvmrc file. I *highly* recommend you use RVM (for every project really). Allow it and it should create a new gemset for you.

Now, after the proper ruby has been picked and you've got a clean gemset, let's get our gemset populated.

	gem install bundler --pre # You may need to install bundler with your fresh gemset – I prefer bundler 1.1 right now
	bundle

Run this command to initialize your sqlite database

	rake init_db
	
### Configure stuff!

Important configurations in config.yml

* `["download_directory"]`

Set your download_directory to a directory you want to drop the torrent files to.

* `["filter_out_less_than_percentage"]`

Change this to lowest percent (based on RTs TomatoMeter) that you want to download.

* `["comments"]["quality"]`

If this is turned on The Rotten Pirate will query the comments on The Pirate Bay for ratings. It will then calculate a score and choose the highest "quality" torrent for you to download. Takes considerably longer but is well worth the wait.

* `["comments"]["num_of_results"]`

The number of search results to query for comments. If there are 30 search results from pirate bay, but you only want to query the top 10 seeded torrents for comments – use this variable.

* `["comments"]["minimum_seeds"]`

Don't query for comments unless there are this many seeds on the torrent (there are hardly any comments for lower seeded torrents)

### Run the process!

	rake execute
	
You'll see the search begin (this can take anywhere from 3 to 5 minutes).

## Run tests

	rspec spec

So far this has been tested on ruby-1.9.2-p290 on OSX 10.6
	
### Play with code

Thanks to echoe, you can get a irb session loaded with the classes loaded inside of it.

	rake console
	TheRottenPirate.execute
	

### Potential TODOS

* Allow for import of top movies?
	* Add more of http://www.rottentomatoes.com/help_desk/syndication_txt.php these
* Have a method of deleting movies (or at least whiping the database clean)
* I'm getting some Timeout::Errors when I'm downloading too many torrents at once. Can we catch those?
* easily configurable cron jobs for getting the rake task to run. (but when does rotten tomatoes update their feeds?)
* Don't bother to download if the quality isn't up to this rating.
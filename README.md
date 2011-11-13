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
	
At this point you'll get prompted by RVM to trust this new .rvmrc file. I *highly* recommend you use RVM (for every project). If you want to use ruby-1.9.2-p290 (the chosen ruby in the .rvmrc file) you're welcome to use your own.

Now, after the proper ruby has been picked and you've got a clean gemset, let's get our gemset populated.

	gem install bundler --pre # You may need to install bundler (I prefer bundler 1.1 right now)
	bundle

Run this command to initialize your sqlite database

	rake init_db
	
### Configure stuff!

Important configurations in config.yml

	download_directory: Set your download_directory to a directory you want to drop the torrent files to.
	filter_out_less_than_percentage: Change this to whatever percent threshold you can handle watching.

Most other stuff is already configured and has been attempted to be optimized, if you're looking to improve speed you might try tweaking the quality or results_to_analyze configs.

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

Don't bother taking the time requesting comments from the pirate bay if there is less than (some configurable amount) number of seeds
Make sure if there are no ratings that first seeded wins (pretty sure this is already happening)
Allow for import of top movies?
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
 - Prowl support to send push notifications to iOS!
 - Also, command line interface to download any single movie you want (e.g. rake download["The Big Lebowski"])

Pretty neat, yeah?

### Setup

Clone the source and install proper gems

	git clone git@github.com:hjhart/the_rotten_pirate.git
	cd the_rotten_pirate
	
At this point if RVM is installed you'll get prompted to trust this new .rvmrc file. I *highly* recommend you use RVM (for every project really). Allow it and it should create a new gemset for you.

Now, after the proper ruby has been picked and you've got a clean gemset, let's get our gemset populated.

	gem install bundler --pre # You may need to install bundler with your fresh gemset – I prefer bundler 1.1 right now
	bundle

Run this command to initialize your sqlite database and make working copies of the config files.

	rake initialize
	
### Configure stuff!

Important configurations in config/config.yml

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

* `[+rottentomatoes_rss_url]`

The URL to fetch the feed from.  See: http://www.rottentomatoes.com/help_desk/syndication_txt.php

If you want to configure prowl notifications, see section below.

### Run the process!

	rake execute
	
You'll see the search begin (this can take anywhere from 10 seconds to 5 minutes) and output will follow.

### Download a Single Movie

	rake download["The Big Lebowski"]
	
This will run the search operation as configured – and download a single torrent file.

### Run tests

	rspec spec

So far this has been tested on ruby-1.9.2-p290 on OSX 10.6
		
### Automate with a cron job

Run `crontab -e` and paste the following into there to start a new cronjob. It will run every 2 days at 12:30am. Make sure the change `cd ~/Sites/the_rotten_pirate` to the directory where your code lives.

	30 0 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31 * * /bin/bash -l -c 'cd ~/Sites/the_rotten_pirate && bundle exec rake execute --silent >> /dev/null 2>&1'

### Play with code

	rake console
	TheRottenPirate.execute

### The algorithm for scoring torrents

Inside of The Pirate Bay results you'll see comments looking like: `"Great movie, A - 10, V - 10"`

This means that the audio track is rated a 10, and the video the same. I'm paginating through every page of comments from the pirate bay and analyzing the comments for those sort of ratings. I then average them up. Since one vote of a 9 should be "scored" less than 5 votes of 9's, I'm adding a booster to scores that have a lot of votes. This boost is calculated on a logarithmic scale (So that 40 votes of 5 doesn't end up beating 5 votes of 9). The boost is then summed to the average rating to produce the total.

When you turn on the `["comments"]["quality"]` setting in the configuration it will parse through the comments and try to find the highest video quality of all the videos. If you turn it off, it will just grab the search result with the highest seeds (for quick downloading) 

### Prowl notifications

- Config goes into config/prowl.yml
  - If this file doesn't exist yet run `rake initialize` once more to create it.
- Fill out your api_key – this can be found at the [prowl api keys](https://www.prowlapp.com/api_settings.php) page.

You'll receive prowl notifications at the end of every run with a rundown of what movies were added.

### Potential TODOS

* Name parser that will take downloaded files and tidy them up!
* Can we search for movies on Amazon/Netflix for instant streaming or purchase?
* Add the ability to organize your files. So, drop the subtitles and the other movie files into another directory.
* Download a single movie rake download "Revenge of the Nerds"
* Generate a little summary of movies that were fetched
	* Synapsis
	* Link to trailer
	* Link to watch the movie
	* Show any screenshots of the movie if they have any
	* Links to download subtitles (if it's a foreign movie?)
* Allow for import of top movies?
	* Add more of http://www.rottentomatoes.com/help_desk/syndication_txt.php these
* Have a method of deleting movies (or at least wiping the database clean)
* I'm getting some Timeout::Errors when I'm downloading too many torrents at once. Should we be catching those?
* Figure out when the rotten tomatoes files update and configure the crontab to run at those times. (DVDS generally come out on Tuesdays, but in some cases they are done other days (e.g. Harry Potter, Twilight, etc...)
* Don't bother to download if the quality isn't up to a configurable rating.
* Database file needs to be not a relative directory. Running specs outside of the root folder fails.

### Support

Tested on ruby 1.9.2-p290 on Mac OSX.
Also tested on ruby 1.8.7-p330 on Mac OSX.


![Counter](http://hjhart.dyndns.org:3003/count.jpg "Counter")

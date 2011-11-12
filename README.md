# The Rotten Pirate?

 - Slurps rotten tomatoes new dvd releases feeds
 - Performs configurable filters on it 
   - e.g. Only certified fresh movies
   - Only movies whose tomatoemeter is greater than 90
   - Movies not already downloaded before (through sqlite database)
 - We then pass along the movies to download to the "Torrent API" gem.
   - The gem looks at comments left by users for ratings of audio and video
   - Performs an average of all ratings given
   - Selects the highest rating (with a reasonable amount of seeds, and at least 5 votes) # This is all subject to change.

## Setup

Clone the source and install proper gems

	git clone git@github.com:hjhart/the_rotten_pirate.git
	cd the_rotten_pirate
	
At this point you'll get prompted by RVM to trust this new .rvmrc file. If you don't have p290 you're welcome to remove and create your own .rvmrc file. Let me know if you get it tested in other rubies.

Now, after the proepr ruby has been picked and you've got a clean gemset

	bundle

Run this command to initialize your sqlite database

	rake init_db
	
## Run tests

	rspec spec
	
So far this has been tested on ruby-1.9.2-p290 on OSX 10.6

## Process

Rotten Tomatoes -> The Rotten Pirate -> Download torrents to a directory -> Torrent program watching directory begins download.

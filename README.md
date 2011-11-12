# The Rotten Pirate?

The general idea of this will be slurp in some feeds from rotten tomatoes, make sure the rating is decent enough, and then parse it through the torrent_api gem. After that, we'll just automatically download them making it available for us to download whenever. 

## Rotten Tomatoes -> Machine -> Download torrents to a directory -> Torrent program watching directory begins download.


## Setup

Run this command to initialize your sqlite database
	rake init_db
# stcs - Super Trully Cuning Stweeler!

STCS is a tweeter bot that auto scales in terms of followers/friends with a ratio of 30%.
In the process it is also able to retweet relevant tweets and/or copy them, replacing urls with redirections and placing tweet tags.

Functionalities:
 * Streaming Tweet Collection System
 * Bot Functionality
 * URL analyzer
 * URL shortener

## Getting started

You should be using ruby >= 2.2 and run bundle install: 

``` bash  
git clone https://github.com/zafargilani/stcs.git stcs
cd stcs
bundle install 
``` 

Make sure to edit config.yml to set your tweeter account and storage details:

``` yaml  
#tweeter credentials
consumer_key: 'ABC'
consumer_secret: 'DEF'
oauth_token: 'GHI'
oauth_token_secret: 'JKL'

#storage properties
storage_folder: 'MNO'
``` 

Collecting tweets:
``` bash  
ruby stweeler.rb collect 
``` 

Running bot:
``` bash  
ruby stweeler.rb launch_bot
``` 

Running shortener:
``` bash  
cd shortener
bundle install
bin/rake db:migrate RAILS_ENV=development
sudo iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
bin/rails server
``` 

Other commands:

``` bash  
$ ruby stweeler.rb help
Commands:
  stweeler.rb check_malware url              # Scan an URL for malware
  stweeler.rb collect                        # Collect and store tweets using Twitter Sample
  stweeler.rb get_tree_from_page content     # Builds a tree of referenced URLs from the specified URL
  stweeler.rb get_urls_from_twitter content  # Gets urls from text
  stweeler.rb help [COMMAND]                 # Describe available commands or one specific command
  stweeler.rb launch_bot                     # Launches a bot OMG OMG OMG
``` 


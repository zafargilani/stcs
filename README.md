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

## Troubleshooting of rails server

If sqlite3 is not installed by bundle install, try (might need sudo):

``` bash
apt-get update
apt-get install sqlite3
apt-get install libsqlite3-dev
```

If you see "Could not find a JavaScript runtime", try (might need sudo):

``` bash
apt-get update
apt-get install nodejs
```

If your rake command gets stuck try:

``` bash  
spring stop
``` 

If your requests are not getting through to the shortener:

``` bash  
sudo iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
``` 

If you want to use the default port 80 (might need sudo):

``` bash
bin/rails server -p 80
```

If on request you get "Cannot render console", try adding the following to the "config/application.rb":

``` ruby  
config.web_console.whiny_requests = false
``` 

## Deploying Rails on Apache2

[How to do Ruby on Rails Apache with Passenger](https://nathanhoad.net/how-to-ruby-on-rails-ubuntu-apache-with-passenger)

[How to setup a Rails app with Apache and Passenger](https://www.digitalocean.com/community/tutorials/how-to-setup-a-rails-4-app-with-apache-and-passenger-on-centos-6)

[Purge or recreate a Ruby on Rails database](http://stackoverflow.com/questions/4116067/purge-or-recreate-a-ruby-on-rails-database)

Permissions:

``` bash
cd stcs/shortener/
sudo chmod -R 777 db/
sudo chmod -R 755 public/
```

## Installing Ruby, RVM and bundler

Install RVM and set default Ruby to version 2.2 (https://rvm.io/rvm/install):

``` bash
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable --ruby
source /home/cloud-user/.rvm/scripts/rvm
rvm install 2.2
rvm --default 2.2
ruby -v
```

If you see "Could not find 'bundler'" upon "bundle install", try: 

``` bash
gem install bundle
bundle update
```

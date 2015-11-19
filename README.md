# stcs - Super Trully Cuning Stweeler!

STCS is a tweeter bot platform for analysis.
Its bots are able to automatically follow users from the twitter stream and maintain a predefined ratio of followers/friends (default: 30%).
It is also able to retweet relevant tweets and/or copy them, replacing urls with redirections and placing tweet tags.
Url redirection is useful to retrieve http header information, such as user agents, as well as to manage cookies.
It can potentially be extended to work as a proxy, in order to inject functionality into linked pages.

Functionalities:
 * Streaming Tweet Collection System - uses the stream apis to collect and dump user tweets
 * Bot Functionality - manages a twitter account, following, retweeting, etc
 * URL analyzer - provides algorithms to retrieve urls and currently some pocs of malware detection
 * URL shortener - rails project to generate shortened urls and interact with the bot

## Getting started

You should be using ruby >= 2.2 and run bundle install: 

``` bash  
git clone https://github.com/zafargilani/stcs.git stcs
cd stcs
bundle install 
``` 

To get started you should create a config.yml file. You can do it by copying our template:

``` bash  
cp config.yml.template config.yml
``` 

You should modify the config.yml to include your tweeter account and storage details:

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

The bot can be configured from the config.yml as well:

``` yaml  
# 15 follows each 15 min. i.e., 1440 follows per day
follow_number: 15
#in minutes
follow_frequency: 15

#will unfollow until the follower ratio is: 
follower_ratio: 0.3
#unfollow will occur every N hours:
unfollow_frequency: 48

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

## Troubleshooting

If sqlite3 is not installed by bundle install, try:

``` bash
sudo apt-get install sqlite3 libsqlite3-dev
```

If you see "Could not find a JavaScript runtime", try:

``` bash
sudo apt-get install nodejs
```

If your rake command gets stuck try:

``` bash  
spring stop
``` 

If your requests are not getting through to the shortener (assumes port 3000):

``` bash  
sudo iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
``` 

If you want to use the default port 80 and dont want to integrate with apache (might need sudo):

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

Note that although db folder is writable, access to it is rejected except for localhost:

``` bash
cd stcs/shortener/
sudo chmod -R 777 db/
sudo chmod -R 755 public/
```

Additionallly .htaccess can be used to limit the access to the db folder.

## Installing Ruby, RVM and bundler

Install RVM and set default Ruby to version 2.2 (https://rvm.io/rvm/install):

``` bash
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable --ruby
source /home/cloud-user/.rvm/scripts/rvm
rvm install 2.2
rvm use 2.2
ruby -v
```

If you see "Could not find 'bundler'" upon "bundle install", try: 

``` bash
gem install bundle
bundle update
```

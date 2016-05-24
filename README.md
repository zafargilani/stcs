# stcs - Super Trully Cuning Stweeler!

STCS is a tweeter bot platform for analysis on Twitter. Find research work using this platform [here](http://dl.acm.org/citation.cfm?id=2889360). Find more [here](http://www.cl.cam.ac.uk/~szuhg2/).

Its bots are able to automatically follow users from the twitter stream and maintain a predefined ratio of followers/friends (default: 30%).

It is also able to retweet relevant tweets and/or copy them, replacing urls with redirections and placing tweet tags.

Url redirection is useful to retrieve http header information, such as user agents, as well as to manage cookies.

It can potentially be extended to work as a proxy, in order to inject functionality into linked pages.

Functionalities:
 * Streaming Tweet Collection System - uses the stream apis to collect and dump user tweets
 * Bot Functionality - manages a twitter account, following, retweeting, etc
 * URL analyzer - provides algorithms to retrieve urls and currently some pocs of malware detection
 * URL shortener - rails project to generate shortened urls and interact with the bot
 * BotOrNot - python project to find if a twitter account is an automated program (bot) or human

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

If you get a [connection timeout error](https://github.com/sferik/twitter/issues/709) from the use of the twitter gem, e.g.: 

``` bash
<...> "connection.rb:16:in `initialize': Connection timed out - connect(2) for "199.59.148.139" port  (Errno::ETIMEDOUT)"
```

Either try updating this project to a more recent version of twitter by switching the twitter version in the Gemfile or in case version 6 didnt come out yet, try the following (remember to switch <YOUR_STCS_FOLDER> by your stcs folder):

``` bash
git clone https://github.com/sferik/twitter.git twitter
cd twitter
vi lib/twitter/streaming/connection.rb
# change this line : client = @tcp_socket_class.new(Resolv.getaddress(request.uri.host), request.uri.port)
# to this: client = @tcp_socket_class.new(Resolv.getaddress(request.uri.host), 443)
gem build twitter.gemspec
gem install twitter-5.15.0.gem
cd <YOUR_STCS_FOLDER>
vi Gemfile
#change the twitter version to 5.15.0
bundle install
```
And now you should be able to execute stcs without the connection timeout error. 

If shortener version is outdated or you see 'undefined method `extract_token'' then do the same for shortener, i.e.: clone, build, install:

``` bash
git clone https://github.com/jpmcgrath/shortener.git
gem build shortener.gemspec
gem install shortener-0.5.5.gem

```

If you see a "Connection timeout error" then simply retry launching your bot.

If you see a "invalid or expired token" error then try issuing new tokens for your application. In some cases you might need to delete the application and create a new one. View [a discussion on this topic](http://stackoverflow.com/questions/17636701/twitter-api-reasons-for-invalid-or-expired-token). The [Twitter GET account/verify accounts page](https://dev.twitter.com/rest/reference/get/account/verify_credentials) helps to find if your application tokens are valid (HTTP 200 OK) or not (HTTP 401). See [OAuth flow here](http://oauth.net/core/1.0/#anchor9).

If you see a "Over capacity error / ServiceUnavailable error" then simply retry launching your bot. See [Twitter Service Status here](https://dev.twitter.com/overview/status).

## Deploying Rails on Apache2

[How to do Ruby on Rails Apache with Passenger](https://nathanhoad.net/how-to-ruby-on-rails-ubuntu-apache-with-passenger)

[Purge or recreate a Ruby on Rails database](http://stackoverflow.com/questions/4116067/purge-or-recreate-a-ruby-on-rails-database)

Permissions:

Note that although db folder is writable, access to it is rejected except for localhost:

``` bash
cd stcs/shortener/
sudo chmod -R 777 db/
sudo chmod -R 755 public/
sudo chmod -R 0664 log/
```

If the Apache2 service fails to start (may be because something got messed up with Phusion Passenger), then do the following:

``` bash
bundle clean --force
sudo gem install passenger
sudo passenger-install-apache2-module
bundle install
sudo service apache2 start
```

## Installing Ruby, RVM and bundler

Install RVM and set default Ruby to version 2.2 (https://rvm.io/rvm/install):

``` bash
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable --ruby
source /home/cloud-user/.rvm/scripts/rvm
rvm install 2.2
rvm --default use 2.2
ruby -v
```

Note: you can select to [use a different version of Ruby](https://rvm.io/rubies/default) on your system later on by:
``` bash
rvm list
rvm use [version]
ruby -v
``` 

If you see "Could not find 'bundler'" upon "bundle install", try: 

``` bash
gem install bundle
bundle update
```

## Add-Ons

### BotOrNot (experimental / working)

To install BotOrNot visit [BotOrNot GitHub page](https://github.com/truthy/botornot-python).

Running BotOrNot:
``` bash
$ ruby lib/classifier.rb
```

Running selector (classification of criteria-based selected accounts):
``` bash
$ ruby lib/selector.rb
```

### Ruby-FANN (experimental / example)

To install Ruby-FANN visit [Ruby-FANN GitHub page](https://github.com/tangledpath/ruby-fann)

Running example program:
``` bash
$ ruby lib/fann.rb
```

### kmeans-clusterer (experimental / example)

To install kmeans-clusterer visit [kmeans-clusterer GitHub page](https://github.com/gbuesing/kmeans-clusterer)

Running example program:
``` bash
$ ruby lib/kmeans.rb
```


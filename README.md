# stcs - Super Truly Cunning Stweeler!

Stweeler (STCS) is a Twitter platform for (1) bot mastering (creating honeypots), and (2) independent bot analysis. Stweeler is developed in Ruby, Python, and Java, and aims to study automation on social networks, particularly Twitter. Research work using Stweeler:
1. [WWW'16](http://www.cl.cam.ac.uk/~szuhg2/docs/papers/p37-gilani.pdf),
2. [WWW'17](http://www.cl.cam.ac.uk/~szuhg2/docs/papers/pp051-gilani.pdf).

Find more [here](http://www.cl.cam.ac.uk/~szuhg2/).

The bot is able to automatically follow users from the twitter stream and maintain a predefined ratio of followers/friends (default: 30%). It is also able to retweet relevant tweets and/or copy them, replacing urls with redirections and placing tweet tags. URL redirection is useful to retrieve http header information, such as user agents, as well as to manage cookies.

Stweeler also has a raw tweet collection system and a bunch of other useful tools. See below for packages and functionalities.

Functionalities:
 * Streaming Tweet Collection System - uses the [twitter ruby gem](https://github.com/sferik/twitter) and Twitter's Streaming API to collect and dump user tweets. This module is independent of the bot tool. [Stats and Graphs package](https://github.com/zafargilani/stcs#stats-and-graphs-package) explains how to use raw Twitter data for useful stats that enable peeking inside bot activity on Twitter.
 * Bot Functionality - the automated program or [bot](https://github.com/mispy/twitter_ebooks) manages a twitter account, following, retweeting, etc.
 * URL analyzer - provides algorithms to retrieve urls and detect malware. It can be extended to work as a proxy, in order to inject functionality into linked pages.
 * URL shortener - [shortener](https://github.com/jpmcgrath/shortener) rails project to generate shortened urls and interact with the bot.
 * Stweeler classifier (rfclassifier) - a python project that uses [scikit-learn](http://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestClassifier.html) toolkit to classify Twitter accounts as 'bot' or 'human'. It utilises Random Forests ensemble classification method and only the most meaningful 22 features (discerned from our detailed [characterisation study](https://arxiv.org/abs/1704.01508)) to produce an accurate output.
 * BotOrNot - [botornot](https://github.com/truthy/botornot-python) is a python project to find if a Twitter account is an automated program (bot) or human.

## Getting started

You should be using ruby >= 2.2. You can install ruby (only short instructions here, please see [here](https://rvm.io/rvm/install) and [here](http://railsapps.github.io/installrubyonrails-ubuntu.html) for details):

``` bash
sudo apt-get update
sudo apt-get install curl
\curl -L https://get.rvm.io | bash -s stable --ruby
rvm get stable --autolibs=enable
rvm install ruby
source ~/.rvm/scripts/rvm
rvm --default use ruby-<version>
```

Run bundle install (to install all dependencies/gems in project Gemfile). This will deploy the bot, not the shortener or the rails web server, for that see [Deploying Rails on Apache2](https://github.com/zafargilani/stcs#deploying-rails-on-apache2) below:

``` bash  
cd ~
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

## Deploying Rails on Apache2

First clone the repository in the /var/www/html/ so the shortener can be deployed:

``` bash
cd /var/www/html
sudo git clone https://github.com/zafargilani/stcs.git stcs
cd stcs
bundle install
```

For the page [How to do Ruby on Rails Apache with Passenger](https://nathanhoad.net/how-to-ruby-on-rails-ubuntu-apache-with-passenger):

``` bash
sudo apt-get install ruby-full build-essential
sudo apt-get install apache2 apache2-dev
sudo gem install rails
sudo gem install passenger
sudo passenger-install-apache2-module
```

Issues: The page asks to install apache2-mpm-prefork, apache2-prefork-dev but both are not unavailable. In this case it is better to install apache2-dev as directed above.

Copy LoadModule script at the bottom of /etc/apache2/apache2.conf file:

``` bash
LoadModule passenger_module /home/szuhg2/.rvm/gems/ruby-2.2.4/gems/passenger-5.0.28/buildout/apache2/mod_passenger.so
   <IfModule mod_passenger.c>
     PassengerRoot /home/szuhg2/.rvm/gems/ruby-2.2.4/gems/passenger-5.0.28
     PassengerDefaultRuby /home/szuhg2/.rvm/gems/ruby-2.2.4/wrappers/ruby
   </IfModule>
```

Then enable mod_rewrite for Apache2:

``` bash
sudo a2enmod rewrite
```

Modify /etc/apache2/sites-available/000-default.conf as follows:

``` bash
<VirtualHost *:80>
        ServerName svr-szuhg2-web.cl.cam.ac.uk

        RailsEnv development

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/stcs/shortener/public

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

Enable the site and restart:

``` bash
sudo a2ensite 000-default.conf
service apache2 restart
```

Might need to add an entry to /etc/hosts:

``` bash
127.0.0.1     svr-szuhg2-web.cl.cam.ac.uk
```

In case the web server doesn't seem to listen to port 80 (netstat -nutlep):

``` bash
ufw allow 80
```

The most important bit of shortener - Creating db, creating shortened_urls table, migrating db to rails:

``` bash  
cd shortener
bundle install
rails generate shortener
bin/rake db:migrate RAILS_ENV=development
```

Running rails server for debug purposes (starting/restarting Apache2 should automatically start rails server):

``` bash
cd shortener
bin/rails server
```

[Purge or recreate a Ruby on Rails database](http://stackoverflow.com/questions/4116067/purge-or-recreate-a-ruby-on-rails-database)

Permissions:

Note that although db folder is writable, access to it is rejected except for localhost:

``` bash
cd stcs/shortener/
sudo chmod -R 777 db/
sudo chmod -R 755 public/
sudo chmod -R 0664 log/
```

If the above permissions for log/ and log/development.log fail then try the following:
``` bash
sudo chmod -R 777 log/
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
cd ~
git clone https://github.com/sferik/twitter.git twitter
cd twitter
vi lib/twitter/streaming/connection.rb
# change this line : client = @tcp_socket_class.new(Resolv.getaddress(request.uri.host), request.uri.port)
# to this: client = @tcp_socket_class.new(Resolv.getaddress(request.uri.host), 443)
gem build twitter.gemspec
gem install twitter-5.16.0.gem
cd <YOUR_STCS_FOLDER>
vi Gemfile
#change the twitter version to 5.15.0
bundle install
```
And now you should be able to execute stcs without the connection timeout error. 

If shortener version is outdated or you see 'undefined method `extract_token'' then do the same for shortener, i.e.: clone, build, install:

``` bash
cd ~
git clone https://github.com/jpmcgrath/shortener.git shortener
gem build shortener.gemspec
gem install shortener-0.5.5.gem

```

If you see a "Connection timeout error" then simply retry launching your bot.

If you see a "invalid or expired token" error then try issuing new tokens for your application. In some cases you might need to delete the application and create a new one. View [a discussion on this topic](http://stackoverflow.com/questions/17636701/twitter-api-reasons-for-invalid-or-expired-token). The [Twitter GET account/verify accounts page](https://dev.twitter.com/rest/reference/get/account/verify_credentials) helps to find if your application tokens are valid (HTTP 200 OK) or not (HTTP 401). See [OAuth flow here](http://oauth.net/core/1.0/#anchor9).

If you see a "Over capacity error / ServiceUnavailable error" then simply retry launching your bot. See [Twitter Service Status here](https://dev.twitter.com/overview/status).

## Add-Ons

### Stats and Graphs package

The Stweeler project provides a number of scripts to produce statistics and graphs from raw Twitter data. These are listed under lib/stats and lib/graphs. Each script provides a method by which it can be used to produce statistics and graphs.

### Stweeler classifier

The Stweeler classifier uses a number of features (22, most recently, discerned from out detailed [characterisation study](https://arxiv.org/abs/1704.01508)) to classify an account as either 'bot' or 'human'. It utilises the Random Forests ensemble classification package from the [scikit-learn](http://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestClassifier.html) toolkit.

[Install the scikit-learn](http://scikit-learn.org/stable/install.html) python library:
``` bash
pip install -U scikit-learn
```

The classifier can be used in two ways. For executing examples:
``` bash
python rfclassifier.py examples
```

The second execution method can take an input file (same format as example) and produce an output file (same format as example):
``` bash
python rfclassifier.py /input/file /output/file
```

### BotOrNot

To install BotOrNot visit [BotOrNot GitHub page](https://github.com/truthy/botornot-python).

To run BotOrNot from within Stweeler, use the following commands. The Ruby script interfaces with a local copy of BotOrNot's Python API and uses a threshold score of 0.50 (as can be inferred from [BotOrNot webpage](http://truthy.indiana.edu/botornot/)).

Running BotOrNot:
``` bash
$ ruby lib/botornot.rb /input/file[accts] /output/file[classifications]
```

The Ruby script accepts an input file with Twitter handles in the following format:
``` bash
katyperry
BarackObama
```

And produces the following as output file:
``` bash
"katyperry","human"
"BarackObama","bot"
```

You may also run BotOrNot in its purest form, to collect statistics instead of labels:
``` bash
$ ruby bon.rb @oliviataters
```

This produces the following pure output:
``` bash
{
    "categories": {
        "content_classification": 0.34,
        "friend_classification": 0.42,
        "network_classification": 0.3,
        "sentiment_classification": 0.4,
        "temporal_classification": 0.55,
        "user_classification": 0.49
    },
    "meta": {
        "screen_name": "oliviataters",
        "user_id": "2216299843"
    },
    "score": 0.51
}
```


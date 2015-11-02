# stcs
Streaming Tweet Collection System

Usage:

Make sure to edit config.yml to set your tweeter account and storage details:

``` yaml  
#tweeter credentials
consumer_key: 'XXX'
consumer_secret: 'XXX'
oauth_token: 'XXX'
oauth_token_secret: 'XXX'

#storage properties
storage_folder: 'XXX'
``` 

Collecting tweets:
``` bash  
ruby stweeler.rb collect 
``` 

Other commands:
``` bash  
ruby stweeler.rb help 
``` 


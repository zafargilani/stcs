# stcs - Super Trully Cuning Stweeler!

Functionalities:
 * Streaming Tweet Collection System
 * Bot Functionality
 * URL analyzer

Usage:

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

Other commands:
``` bash  
ruby stweeler.rb help 
``` 


# DeBot Python API
A Python API for [DeBot](http://cs.unm.edu/~chavoshi/debot).

## Install instructions

1. Clone this repository and enter the folder:
2. `python setup.py install`


## Get the list of the detected bots
Given a date as the input, the "get_bots_list" function returns all the clusters of bots that Debot detected on that date. In the following example, we want to get the list of the bots detected on December 4th 2015. The output shows 2 clusters containing 8 bots totally. 
```python
import debot

db = debot.DeBot('your_api_key')
db.get_bots_list('2015-12-04')
```

Output:
```xml
<?xml version="1.0"?>
<response status="success">
 <date>2015-12-04</date>
 <cluster cluster_id="1" size="5">
  <user>
   <id>12359852135</id>
   <screen_name>ma_arrioja</screen_name>
  </user>
  <user>
   <id>85642135261</id>
   <screen_name>Napebar23Perez</screen_name>
  </user>
  .
  .
  .
 </cluster>
 <cluster cluster_id="2" size="3">
  <user>
   <id>2564853141</id>
   <screen_name>MadridReal</screen_name>
  </user>
  .
  .
  .
 </cluster>
</response>
```

## Check a Twitter Account
Given a Twitter user name, the "check_user" function checks whether or not DeBot has detected the given account as a bot so far. If yes, it also returns the date of detection and the number of times that account was detected as a bot on that date. In the following example, we query the account "@loveforlover_01", and the output shows that DeBot detected this account as a bot once on 2015-10-28, and 4 times on 2015-12-04. You can also check a user by its Twitter ID.
```python
import debot

db = debot.DeBot('your_api_key')
db.check_user('@loveforlover_01')
```

Output:
```xml
<?xml version="1.0"?>
<response status="success">
 <user>
  <id>6532574884</id>
  <screen_name>loveforlover_01</screen_name>
  <dates>
   <date count="1">2015-10-28</date>
   <date count="4">2015-12-04</date>
  </dates>
 </user>
 <user>
  <id>1498736854</id>
  <screen_name>loveforlover_01</screen_name>
  <dates>
   <date count="2">2016-02-22</date>
   <date count="1">2016-04-06</date>
  </dates>
 </user>
</response>
```

## Get Frequent Bots
Using this function, the user can get the list of bots which appear in our archive more than a given number of times. The input of the function is the minimum number of times the bots are appeared in our archive. The output is a list of bots with number of times each of them has been detected.
```python
import debot

db = debot.DeBot('your_api_key')
db.get_frequent_bots(20)
```

Output:
```xml
<?xml version="1.0"?>
<response status="success">
 <user>
  <id>12359852135</id>
  <frequency>102</frequency>
  <screen_names>
   <screen_name>maFan</screen_name>
   <screen_name>burgerFan</screen_name>
   <screen_name>mama_mia</screen_name>
  </screen_names>
 </user>
</response>
```

## Get Bots Related To a Topic
Given a topic, this function returns all bots who were associated with that topic at some point in the past. It also provides the corresponding dates.
```python
import debot

db = debot.DeBot('your_api_key')
db.get_related_bots('election2016')
```

Output:
```xml
<?xml version="1.0"?>
<response status="success">
 <topic title="election2016">  
  <user>
   <id>12359852135</id>
   <screen_name>m_arrioja</screen_name>
   <date>2016-10-22</date>
  </user>
  <user>
   <id>3562489511</id>
   <screen_name>DNC_</screen_name>
   <date>2016-10-22</date>
  </user>
 </topic>
</response>
```


## Dependencies

* [requests](http://docs.python-requests.org/en/latest/)

You can install requests via pip (you may need sudo access):

    pip install requests
    
## How to get the API key:
To get the key, please click [here](http://www.cs.unm.edu/~chavoshi/debot/api.html).



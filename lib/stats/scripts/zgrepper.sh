#!/bin/bash
zgrep "\"screen_name\":\"SCREENNAME\"" /local/scratch/twitter-data/2016-4-1.uk.txt.gz >> 2016-4.bot.SCREENNAME
zgrep "\"screen_name\":\"SCREENNAME\"" /local/scratch/twitter-data/2016-4-1.uk.txt.gz >> 2016-4.human.SCREENNAME


# usage: python debotwrapper.py /path/to/date_list.txt /path/to/response.xml
import sys
from xml.etree import ElementTree
import debot

db = debot.DeBot('ZimTzjQtwD6lXTACTuJgjhpIyLf465RUe4EDekYA')

# check_user does not work
#db.check_user('@BarackObama')

fr = open(sys.argv[1], 'r')
dates = [date for date in fr.readlines()]
fr.close()
dates = map(lambda s: s.strip(), dates)

fw = open(sys.argv[2], 'w')
for date in dates:
	response = db.get_bots_list(date)
	fw.write(response)
fw.close()


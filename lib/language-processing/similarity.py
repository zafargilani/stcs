# python similarity.py /input/cluster1.txt /input/cluster2.txt
import sys
import difflib as dl # https://docs.python.org/2/library/difflib.html

a = file(sys.argv[1]).read()
b = file(sys.argv[2]).read()

sim = dl.get_close_matches

s = 0
wa = a.split()
wb = b.split()

for i in wa:
	if sim(i, wb):
		s += 1

n = float(s) / float(len(wa))
print '%f' % n


import math
import numpy as np


def forward_diff(h):
	p = (math.exp(h) - math.exp(0)) / h
	return p

if __name__ == '__main__':
	hlist = [1e-2, 1e-4, 1e-6, 1e-8, 1e-10, 1e-12, 1e-20]
	for h in hlist:
		approximate = forward_diff(h)
		error = abs(math.exp(0) - approximate)
		print("{}: value: {}, error: {:.20f}".format(h, approximate, error))
	print(math.exp(1e-8)-1)
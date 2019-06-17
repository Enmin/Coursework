import math

def getSpecfp(initial, index):
	for i in range(index):
		initial = f(initial)
	return initial

def getNextInitial(p0, p1, p2):
	initial = p0 - (p1 - p0) * (p1 - p0) / (p2 - 2*p1 + p0)
	return initial

def f(x):
	return math.cos(x)


if __name__ == '__main__':
	zero_p0 = 1
	zero_p1 = f(zero_p0)
	zero_p2 = f(zero_p1)
	print("Round0: {} {} {}".format(zero_p0, zero_p1, zero_p2))
	first_p0 = getNextInitial(zero_p0, zero_p1, zero_p2)
	first_p1 = f(first_p0)
	first_p2 = f(first_p1)
	print("Round1: {} {} {}".format(first_p0, first_p1, first_p2))
	second_p0 = getNextInitial(first_p0, first_p1, first_p2)
	print("Round2: {}".format(second_p0))
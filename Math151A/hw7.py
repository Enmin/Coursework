import math


def function3(x):
	return 1/(1+x)


def compositTrazp(a, b, n, function):
	h = (b-a)/n
	s = 0
	for i in range(1, n):
		s = s + 2*function(a+i*h)
	value = h / 2 * (function(a) + s + function(b))
	return value

def compositeSimpson(a, b, n, function):
	h = (b-a)/n
	x0 = function(a) + function(b)
	x1 = 0
	x2 = 0
	for i in range(1, n):
		x = a + i*h
		if i%2 == 0:
			x2 = x2 + function(x)
		else:
			x1 = x1 + function(x)
	value = h * (x0 + 2 * x2 + 4 * x1) / 3
	return value


if __name__ == "__main__":
	a = 0
	b = 1
	nlist = [10, 20, 40, 80]
	rightValue = math.log(2) - math.log(1)
	print(rightValue)
	for n in nlist:
		value = compositeSimpson(a, b, n, function3)
		error = abs(value - rightValue)
		nnerror = n*n*error
		print(n, value, error, nnerror)
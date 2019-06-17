import math

def function(x):
	return 3*x - math.exp(x)


def derivativeFunction(x):
	return 3 - math.exp(x)


if __name__ == '__main__':
	p0 = 1
	p1 = 2
	q0 = function(p0)
	q1 = function(p1)
	maxIteration = 1000
	iteration = 1
	tol = 1e-5
	while iteration <= maxIteration:
		p = p1 - q1 * (p1 - p0) / (q1 - q0)
		print(p)
		if abs(p1 - p) < tol:
			print('abs: {} PN: {} iteration: {}'.format(str(abs(p1-p)), p, iteration))
			break
		iteration = iteration + 1
		p0 = p1
		q0 = q1
		p1 = p
		q1 = function(p)
	if iteration == maxIteration:
		print('The method failed after {} iterations'.format(iteration))
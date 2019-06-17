def function(x):
	return x*x - 4*x +3


def derivativeFunction(x):
	return 2*x - 4


if __name__ == '__main__':
	p0 = 2.01
	tol = 1e-5
	iteration = 1
	maxIteration = 1000
	while iteration <= maxIteration:
		p = p0 - function(p0)/derivativeFunction(p0)
		print(p)
		if abs(p - p0) < tol:
			print('abs: {} PN: {} iteration: {}'.format(str(abs(p-p0)), p, iteration))
			break
		p0 = p
		iteration = iteration + 1
	if iteration == maxIteration:
		print('The method failed after {} iterations'.format(iteration))
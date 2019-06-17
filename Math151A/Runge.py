import math
import matplotlib.pyplot as plt
import pandas as pd

def runge(x):
	y = 1 / (x * x + 1)
	return y


def prunge(x, nodelist):
	pfunction = 0
	for k in nodelist:
		f = runge(k)
		l = 1
		for i in nodelist:
			if k != i:
				l = l * (x - i)/(k - i)
		pfunction = pfunction + f*l
	return pfunction


def nodesfunction(k):
	y = 5 * math.cos(k*math.pi/10)
	return y


if __name__ =='__main__':
	nodes = [-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5]
	# nodes = [-5, -4, -3, -2, -1, 0]
	newnodes = [nodesfunction(k) for k in range(0, 11)]
	result= prunge(4, nodelist=nodes)
	# 1
	xlist = []
	pylist = []
	rylist = []
	qylist = []
	for index in range(-50, 51):
		x = index / 10
		py = prunge(x, nodes)
		ry = runge(x)
		qy = prunge(x, newnodes)
		xlist.append(x)
		pylist.append(py)
		rylist.append(ry)
		qylist.append((qy))
	plt.figure()
	plt.subplot(2, 1, 1)
	plt.plot(xlist, pylist, label='P(x)')
	plt.plot(xlist, rylist, label='R(x)')
	plt.xlabel('x')
	plt.ylabel('y')
	plt.legend(loc='best')

	plt.subplot(2, 1, 2)
	plt.plot(xlist, qylist, label='Q(x)')
	plt.plot(xlist, rylist, label='R(x)')
	plt.xlabel('x')
	plt.ylabel('y')
	plt.legend(loc='best')
	plt.show()
	print(newnodes)
	# plt.savefig('5')
import sys
import os
import csv


def dup(block, inode, other):
	offset = 0
	if other == 'INDIRECT BLOCK':
		offset = 12
	elif other == 'DOUBLE INDIRECT BLOCK':
		offset = 268
	elif other == 'TRIPLE INDIRECT BLOCK':
		offset = 65804
	sys.stdout.write('DUPLICATE ' + other + ' ' + str(block) + ' IN INODE ' + str(inode) + ' AT OFFSET ' + str(offset) + '\n')


def checkValid(block, inode, other, offset, last_valid):
	if block < 0 or block > last_valid - 1:
		sys.stdout.write('INVALID ' + other + ' ' + str(block) + ' IN INODE ' + str(inode) + ' AT OFFSET ' + str(offset) + '\n')
		return False
	return True


def checkReserved(block, inode, other, offset, first_valid):
	if first_valid > block > 0:
		sys.stdout.write('RESERVED ' + other + ' ' + str(block) + ' IN INODE ' + str(inode) + ' AT OFFSET ' + str(offset) + '\n')
		return False
	return True


# for clear code
def checkBoth(b, i, o, off, last, first):
	if checkValid(b, i, o, off, last) and checkReserved(b, i, o, off, first):
		return True
	return False


def goThrough(summary):
	# initialization
	inode_size = 0
	block_size = 0
	numOfBlocks = 0
	numOfInodes = 0
	firstUnreservedBlock = 0
	non_res_inode = 0

	# data structure
	blockInfo = dict()
	inodeInfo = dict()
	parentInfo = dict()
	report_link = dict()
	actual_link = dict()
	allocateInodeInfo = list()

	for i in summary:
		i = i.replace('\n', '')
		words = i.split(',')

		if words[0] == 'SUPERBLOCK':
			inode_size = int(words[4])
			block_size = int(words[3])

		elif words[0] == 'BFREE':
			block = int(words[1])
			blockInfo[block] = 'FREE'

		elif words[0] == 'GROUP':
			numOfBlocks = int(words[2])
			numOfInodes = int(words[3])
			first_inode_block = int(words[8])
			numOfInode_Block = (inode_size * numOfInodes / block_size)
			firstUnreservedBlock = first_inode_block + numOfInode_Block

		elif words[0] == 'INDIRECT':
			block = int(words[5])
			inode = int(words[1])
			offset = int(words[3])
			other = 'BLOCK'
			if int(words[2]) == 1:
				other = 'INDIRECT BLOCK'
			elif int(words[2]) == 2:
				other = 'DOUBLE INDIRECT BLOCK'
			elif int(words[2]) == 3:
				other = 'TRIPLE INDIRECT BLOCK'

			if block in blockInfo:
				if blockInfo[block] == 'FREE':
					sys.stdout.write('ALLOCATED BLOCK ' + str(block) + ' ON FREELIST\n')
				else:
					# if not FREE, must be assigned in blockInfo
					dup(block, inode, other)
					dup(block, blockInfo[block][0], blockInfo[block][1])
				continue
			if checkBoth(block, inode, other, offset, numOfBlocks, firstUnreservedBlock):
				blockInfo[block] = (inode, other)

		elif words[0] == 'INODE':
			inode = words[1]
			# 12 is start of block data pos, 27 is end of block data pos
			for n in range(12, 27):
				block = int(words[n])
				if block != 0 and n < 24 and block not in blockInfo:
					if checkBoth(block, inode, 'BLOCK', 0, numOfBlocks, firstUnreservedBlock):
						blockInfo[block] = (inode, 'BLOCK')
				elif block != 0 and n == 24 and block not in blockInfo:
					if checkBoth(block, inode, 'INDIRECT BLOCK', 12, numOfBlocks, firstUnreservedBlock):
						blockInfo[block] = (inode, 'INDIRECT BLOCK')
				elif block != 0 and n == 25 and block not in blockInfo:
					if checkBoth(block, inode, 'DOUBLE INDIRECT BLOCK', 268, numOfBlocks, firstUnreservedBlock):
						blockInfo[block] = (inode, 'DOUBLE INDIRECT BLOCK')
				elif block != 0 and n == 26 and block not in blockInfo:
					if checkBoth(block, inode, 'TRIPLE INDIRECT BLOCK', 65804, numOfBlocks, firstUnreservedBlock):
						blockInfo[block] = (inode, 'TRIPLE INDIRECT BLOCK')
				elif block != 0 and blockInfo[block] == 'FREE':
					sys.stdout.write('ALLOCATED BLOCK ' + str(block) + ' ON FREELIST\n')
				elif block != 0 and blockInfo[block] != 'FREE':
					other = 'BLOCK'
					if n == 24:
						other = 'INDIRECT BLOCK'
					elif n == 25:
						other = 'DOUBLE INDIRECT BLOCK'
					elif n == 26:
						other = 'TRIPLE INDIRECT BLOCK'
					dup(block, inode, other)
					dup(block, blockInfo[block][0], blockInfo[block][1])

	for i in range(int(firstUnreservedBlock), int(numOfBlocks)):
		if i not in blockInfo:
			sys.stdout.write('UNREFERENCED BLOCK ' + str(i) + '\n')

	summary.seek(0)
	for i in summary:
		i = i.replace('\n', '')
		words = i.split(',')
		inode = int(words[1])
		if words[0] == 'SUPERBLOCK':
			numOfInodes = int(words[2])
			non_res_inode = int(words[7])
		elif words[0] == 'INODE' and inode not in inodeInfo:
			inodeInfo[inode] = 'ALLOCATED'
		elif words[0] == 'INODE':
			sys.stdout.write('ALLOCATED INODE ' + str(inode) + ' ON FREELIST\n')
			inodeInfo[inode] = 'ALLOCATED'
		elif words[0] == 'IFREE':
			inodeInfo[inode] = 'FREE'

	for i in range(int(non_res_inode), int(numOfInodes + 1)):
		if i not in inodeInfo:
			sys.stdout.write('UNALLOCATED INODE ' + str(i) + ' NOT ON FREELIST\n')

	summary.seek(0)
	for i in inodeInfo:
		if inodeInfo[i] != 'FREE':
			allocateInodeInfo.append(i)
	for i in allocateInodeInfo:
		del inodeInfo[i]

	for i in summary:
		words = i.split(',')
		if words[0] == 'INODE':
			inode = int(words[1])
			report_link[inode] = int(words[6])
			actual_link[inode] = 0

	# link
	summary.seek(0)
	for i in summary:
		i = i.replace('\n', '')
		words = i.split(',')
		if words[0] == 'DIRENT':
			ref_file_inode = int(words[3])
			parent_inode = int(words[1])
			directory = words[6]

			if directory == "'.'" and ref_file_inode != parent_inode:
				sys.stdout.write('DIRECTORY INODE ' + str(parent_inode) + ' NAME ' + directory + ' LINK TO INODE ' + str(ref_file_inode) + ' SHOULD BE ' + str(parent_inode) + '\n')
			elif directory == "'..'":
				grandparent = parentInfo[parent_inode]
				if ref_file_inode != grandparent:
					sys.stdout.write('DIRECTORY INODE ' + str(parent_inode) + ' NAME ' + directory + ' LINK TO INODE ' + str(ref_file_inode) + ' SHOULD BE ' + str(grandparent) + '\n')
			if ref_file_inode in inodeInfo:
				sys.stdout.write('DIRECTORY INODE ' + str(parent_inode) + ' NAME ' + directory + ' UNALLOCATED INODE ' + str(ref_file_inode) + '\n')
			elif ref_file_inode not in inodeInfo and ref_file_inode not in report_link:
				sys.stdout.write('DIRECTORY INODE ' + str(parent_inode) + ' NAME ' + directory + ' INVALID INODE ' + str(ref_file_inode) + '\n')
			else:
				actual_link[ref_file_inode] += 1
				if ref_file_inode not in parentInfo:
					parentInfo[ref_file_inode] = parent_inode

	for inode in report_link:
		if actual_link[inode] != report_link[inode]:
			sys.stdout.write('INODE ' + str(inode) + ' HAS ' + str(actual_link[inode]) + ' LINKS BUT LINKCOUNT IS ' + str(report_link[inode]) + '\n')


def main():
	if len(sys.argv) != 2:
		sys.stderr.write('Wrong Arguments: ./lab3b [summary.csv]!\n')
		exit(1)
	try:
		summary = open(sys.argv[1])
		goThrough(summary)
		summary.close()
	except OSError:
		sys.stderr.write('OSError Open.\n')
		exit(1)
	except IOError:
		sys.stderr.write('IOError.\n')
		exit(1)


main()

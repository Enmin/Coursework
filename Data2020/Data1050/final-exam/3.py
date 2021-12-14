def mergeSort(arr):
    if len(arr) > 1:
        # Finding the mid of the array
        mid = len(arr) // 2
        # Dividing the array elements
        L = arr[:mid]
        # into 2 halves
        R = arr[mid:]
        # Sorting the first half
        mergeSort(L)
        # Sorting the second half
        mergeSort(R)
        i = j = k = 0
        # check the criteria for best case
        # here i use <= and < to preserve the original order if two elements are the same in arr
        if L[-1] <= R[0]:
            for t in range(0, len(L)):
                arr[t] = L[t]
            for t in range(len(L), len(L) + len(R)):
                arr[t] = R[t-len(L)]
        elif R[-1] < L[0]:
            for t in range(0, len(R)):
                arr[t] = R[t]
            for t in range(len(R),len(R) + len(L)):
                arr[t] = L[t-len(R)]
        else:
            while i < len(L) and j < len(R):
                if L[i] < R[j]:
                    arr[k] = L[i]
                    i += 1
                else:
                    arr[k] = R[j]
                    j += 1
                k += 1
            # Checking if any element was left
            while i < len(L):
                arr[k] = L[i]
                i += 1
                k += 1
            while j < len(R):
                arr[k] = R[j]
                j += 1
                k += 1


def test_merge_sort():
    arr = [12, 11, 13, 5, 6, 7]
    mergeSort(arr)
    assert arr == [5,6,7,11,12,13]


if __name__ == '__main__':
    test_merge_sort()

'''
The worst case for Bubble sort is O(n^2) and the best case is O(n). Because if keep track of the number of swaps in each pass, in the first pass, we can terminate the program if no exchanges are made, which takes n-1 steps and the time complexity is O(n). The worst case and best case for Heap sort are both O(nlogn). The best case is still O(nlogn) because when all elements are equal (O(n), since you don't have to reheapify after every removal, which takes log(n) time since the max height of the heap is log(n)). When a list is fully sorted, Bubble sort will perform better.

Timsort is adaptive, which has O(n) in best case and O(nlogn) in the worst case.
Insertion sort is adaptive, which has O(n) in best case and O(n^2) in the worst case.
Selection sort is non-adaptive, which has O(n^2) in both best and worst case.
Bucket sort is adaptive, which has O(n+k) in best case and O(n^2) in the worst case.

Since in the merge step of two sub sorted lists, we need to compare each element of two sublists to get a sorted merged list of the two. However, if we compare the last element x  of sublist 1 and the first element y of the sublist 2, we can directly append 2 to the tail of 1 if x is larger than y. In this case, we can shorten the time we need in merging and get a time complexity of O(logn) for a fully sorted list.

'''
'''
Input: 2 arugments
    array - a list of numbers
    targetSum - a number
Output: 1 pair of numbers

Special Cases: when no two numbers in array add up to
targetSum, we return an empty pair "()" or "[]"
'''

def twoNumberSum(array, targetSum):
    array.sort()
    lp = 0
    rp = len(array)-1
    while array[lp] + array[rp] != targetSum:
        if lp >= rp:
            return []
        elif array[lp] + array[rp] > targetSum:
            rp = rp -1
        elif array[lp] + array[rp] < targetSum:
            lp = lp + 1
    return [array[lp], array[rp]]

def test_twoNumberSum():
    assert(twoNumberSum([1,2,5], 6) == [1,5])
    assert(twoNumberSum([1,2,4,5,7,8,9,0], 15) == [7,8])
    assert(twoNumberSum([2,3,4,5,6], 20) == [])

if __name__ == '__main__':
    test_twoNumberSum()
    print("pass")

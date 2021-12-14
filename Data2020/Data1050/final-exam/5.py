def parent(i, n):
    # time complexity O(1): space: O(2)
    # return None if it is the root
    # else track the children by index in the mathematical formula
    if i == 0:
        return None
    elif i // 2 == 0:
        return (i-2) / 2
    else:
        return (i-1) / 2

def left_child(i, n):
    # time complexity O(1): space: O(2)
    # return None if out of list length
    if i * 2 + 1 < n:
        return i*2+1
    return None

def right_child(i, n):
    # time complexity O(1): space: O(2)
    # return None if out of list length
    if i * 2 + 2 < n:
        return i * 2 + 2
    return None

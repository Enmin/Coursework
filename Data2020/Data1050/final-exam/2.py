class MaxMeanMinStack():
    # O(1) time | O(1) space
    def __init__(self):
        "Initalizes an instance of the class"
        self.maxStack = []
        self.minStack = []
        self.meanStack = []
        self.stack = []

    # O(1) time | O(1) space
    def peek(self):
        "Returns what is on the top of stack but does not remove it"
        return self.stack[-1]

    # O(1) time | O(1) space
    def pop(self):
        "Removes top element from stack and returns it"
        self.maxStack.pop()
        self.minStack.pop()
        self.meanStack.pop()
        return self.stack.pop()

    # O(1) time | O(1) space
    def push(self, number):
        "Adds an element to the top of the stack"
        newMax = number
        newMin = number
        newMean = number
        if len(self.maxStack):
            newMax = max(self.maxStack[-1], number)
        if len(self.minStack):
            newMin = min(self.minStack[-1], number)
        if len(self.meanStack):
            newMean = (self.meanStack[-1] * len(self.meanStack) + number) / (1 + len(self.meanStack))
        self.maxStack.append(newMax)
        self.minStack.append(newMin)
        self.meanStack.append(newMean)
        self.stack.append(number)

    # O(1) time | O(1) space
    def getMax(self):
        "Return the largest item currently in the stack"
        return self.maxStack[-1]

    # O(1) time | O(1) space
    def getMin(self):
        "Return the smallest item currently in the stack"
        return self.minStack[-1]

    # O(1) time | O(1) space
    def getMean(self):
        "Return the mean value currently of the stack"
        return self.meanStack[-1]


def test_MaxMeanMinStack():
    # Q: How do we test a Class?
    ms = MaxMeanMinStack()  # Q: Make an instance, and test that.
    assert ms.maxStack == [], 'init'  # Verify init is working (Whitebox)
    assert ms.minStack == [], 'init'  # Verify init is working (Whitebox)
    assert ms.meanStack == [], 'init'  # Verify init is working (Whitebox)
    ms.push(2)
    assert ms.peek() == 2, 'n=1'
    assert ms.getMax() == 2, 'n=1'
    assert ms.getMin() == 2, 'n=1'
    assert ms.getMean() == 2, 'n=1'
    ms.push(3)
    ms.push(4)
    ms.push(1)
    assert ms.peek() == 1, 'n=1'
    assert ms.getMax() == 4, 'n=1'
    assert ms.getMin() == 1, 'n=1'
    assert ms.getMean() == 2.5, 'n=1'
    ms.pop()
    ms.pop()
    assert ms.peek() == 3, 'n=1'
    assert ms.getMax() == 3, 'n=1'
    assert ms.getMin() == 2, 'n=1'
    assert ms.getMean() == 2.5, 'n=1'


if __name__ == '__main__':
    test_MaxMeanMinStack()

'''
I will add three more lists in the MinMeanMaxQ1Q2Q3 class to record current Q1, Q2 and Q3. These 3 lists perform in the same way as the previous 3 lists and can have O(1) time and space complexity  in all of its in-class functions.

The StatStack will have the same structure as the MaxStack. There is a list in the class called ‘statStack’ and a list called ‘stack’. The getStat function will return the current statistic specified by the user as an input parameter. To update the statStack, the user needs to specify a mathematical way to update the current statistic if a new element is pushed into the stack. Therefore, in the init function, the user has to provide a method to calculate the mathematical update of the ‘statStack’.

'''
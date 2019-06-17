;Question 1: input specifies nth number in the Padovan Sequence
;output is the value of that number specified by the input
;solution: using recursion to loop till n is smaller 3, otherwise
;get the value of sum of n-2 and n-3 numbers in the sequence.
(defun PAD(N)
  (if (< N 3) 1 (+ (PAD (- N 2)) (PAD (- N 3)) )
    )
  )

;Question 2: input specifies nth number in the Padovan Sequence
;output is the number of addition to get that number
;solution: using recursion, the first 3 number does not require
;addition, every number that is bigger than that will add 1 to
;the total addition each time sums is called.
(defun SUMS(N)
  (if (< N 3) 0 (+ (SUMS (- N 2)) (SUMS (- N 3)) 1)
    )
  )

;Question3: input is a list or an atom, output is the original
;with elements replaced by character '?'.
;solution: do recursion with car and cdr to go through the list
;and replace the elements. If input is null, we return nil; if
;input is an atom, we return ? directly; if input is a list and
;car TREE is a list, we call ANON again to approach the car TREE
;and cdr TREE and regroup it back into a list: if car TREE is an
;atom, we replace it with a '? and regroup it with ANON (cdr TREE).
(defun ANON(TREE)
  (cond ((null TREE) nil)
    	((atom TREE) '?)
  	((listp (car TREE)) (cons (ANON (car TREE)) (ANON (cdr TREE))))
	((atom (car TREE)) (cons '? (ANON (cdr TREE))))
    )
  )


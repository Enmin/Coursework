;
; CS161 Hw3: Sokoban
; 
; *********************
;    READ THIS FIRST
; ********************* 
;
; All functions that you need to modify are marked with 'EXERCISE' in their header comments.
; Do not modify a-star.lsp.
; This file also contains many helper functions. You may call any of them in your functions.
;
; *Warning*: The provided A* code only supports the maximum cost of 4999 for any node.
; That is f(n)=g(n)+h(n) < 5000. So, be careful when you write your heuristic functions.
; Do not make them return anything too large.
;
; For Allegro Common Lisp users: The free version of Allegro puts a limit on memory.
; So, it may crash on some hard sokoban problems and there is no easy fix (unless you buy 
; Allegro). 
; Of course, other versions of Lisp may also crash if the problem is too hard, but the amount
; of memory available will be relatively more relaxed.
; Improving the quality of the heuristic will mitigate this problem, as it will allow A* to
; solve hard problems with fewer node expansions.
; 
; In either case, this limitation should not significantly affect your grade.
; 
; Remember that most functions are not graded on efficiency (only correctness).
; Efficiency can only influence your heuristic performance in the competition (which will
; affect your score).
;  
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; General utility functions
; They are not necessary for this homework.
; Use/modify them for your own convenience.
;

;
; For reloading modified code.
; I found this easier than typing (load "filename") every time. 
;
(defun reload()
  (load "hw3.lsp")
  )

;
; For loading a-star.lsp.
;
(defun load-a-star()
  (load "a-star.lsp"))

;
; Reloads hw3.lsp and a-star.lsp
;
(defun reload-all()
  (reload)
  (load-a-star)
  )

;
; A shortcut function.
; goal-test and next-states stay the same throughout the assignment.
; So, you can just call (sokoban <init-state> #'<heuristic-name>).
; 
;
(defun sokoban (s h)
  (a* s #'goal-test #'next-states h)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; end general utility functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; We now begin actual Sokoban code
;

; Define some global variables
(setq blank 0)
(setq wall 1)
(setq box 2)
(setq keeper 3)
(setq star 4)
(setq boxstar 5)
(setq keeperstar 6)

; Some helper functions for checking the content of a square
(defun isBlank (v)
  (= v blank)
  )

(defun isWall (v)
  (= v wall)
  )

(defun isBox (v)
  (= v box)
  )

(defun isKeeper (v)
  (= v keeper)
  )

(defun isStar (v)
  (= v star)
  )

(defun isBoxStar (v)
  (= v boxstar)
  )

(defun isKeeperStar (v)
  (= v keeperstar)
  )

;
; helper function of getKeeperPosition
;
(defun getKeeperColumn (r col)
  (cond ((null r) nil)
	(t (if (or (isKeeper (car r)) (isKeeperStar (car r)))
	       col
	     (getKeeperColumn (cdr r) (+ col 1))
	     );end if
	   );end t
	);end cond
  )

;
; getKeeperPosition (s firstRow)
; Returns a list indicating the position of the keeper (c r).
; 
; Assumes that the keeper is in row >= firstRow.
; The top row is the zeroth row.
; The first (right) column is the zeroth column.
;
(defun getKeeperPosition (s row)
  (cond ((null s) nil)
	(t (let ((x (getKeeperColumn (car s) 0)))
	     (if x
		 ;keeper is in this row
		 (list x row)
		 ;otherwise move on
		 (getKeeperPosition (cdr s) (+ row 1))
		 );end if
	       );end let
	 );end t
	);end cond
  );end defun

;
; cleanUpList (l)
; returns l with any NIL element removed.
; For example, if l is '(1 2 NIL 3 NIL), returns '(1 2 3).
;
(defun cleanUpList (L)
  (cond ((null L) nil)
	(t (let ((cur (car L))
		 (res (cleanUpList (cdr L)))
		 )
	     (if cur 
		 (cons cur res)
		  res
		 )
	     );end let
	   );end t
	);end cond
  );end 

; EXERCISE: Modify this function to return true (t)
; if and only if s is a goal state of a Sokoban game.
; (no box is on a non-goal square)
;
; Currently, it always returns NIL. If A* is called with
; this function as the goal testing function, A* will never
; terminate until the whole search space is exhausted.
;
(defun goal-test (s)
  (cond 
    ((null s) t)
    ((atom s) (not (isBox s)))
    (t (and (goal-test(car s)) (goal-test (cdr s))))
    )
  );end defun

; EXERCISE: Modify this function to return the list of 
; sucessor states of s.
;
; This is the top-level next-states (successor) function.
; Some skeleton code is provided below.
; You may delete them totally, depending on your approach.
; 
; If you want to use it, you will need to set 'result' to be 
; the set of states after moving the keeper in each of the 4 directions.
; A pseudo-code for this is:
; 
; ...
; (result (list (try-move s UP) (try-move s DOWN) (try-move s LEFT) (try-move s RIGHT)))
; ...
; 
; You will need to define the function try-move and decide how to represent UP,DOWN,LEFT,RIGHT.
; Any NIL result returned from try-move can be removed by cleanUpList.
; 
;
; helper function:get-row
; the function takes in a state and a row
; using recursion to go through the map
; outputs the list of sqaures in that row if the row number is valid
(defun get-row (S r)
	(cond
		((< r 0) nil)
		((null S) nil)
		((= r 0) (car S))
		(t (get-row (cdr S) (- r 1)))
	)
)

; helper function get-column
; the function takes in a row, a column
; return the object at row and columun if valid
(defun get-column (row col)
	(cond
		((null row) 1)
		((< col 0) 1)
		((= col 0) (car row))
		(t (get-column (cdr row) (- col 1)))
	)
)

; helper function get-square
; the function takes in a state, a row, a column.
; using previous 2 helper functions to output the object at (r,c) in S
(defun get-square (S row col)
	(get-column (get-row S row) col)
)

; helper function set-square
; the function takes in a row, a column, and a square content value
; output the new sate after setting 
(defun set-row (state col value)
	(cond
		((null state) nil)
		((= col 0) (cons value (set-row (cdr state) (- col 1) value)))
		(t (cons (car state) (set-row (cdr state) (- col 1) value)))
	)
)

; helper function for TRY-MOVE
; The function takes in a state, a row, a column and a square content value(integer)
; Returns a new state S' that is obtain by setting the square (r, c) to value v
(defun set-square (state col row value)
	(cond
		((null state) nil)
		((= row 0) (cons (set-row (car state) col value) (set-square (cdr state) col (- row 1) value)))
		(t (cons (car state) (set-square (cdr state) col (- row 1) value)))
	)
)

; helper funtion for try-move
; The function takes in a state S and keeper's position x for x coor and y for y coor
; check if the move is invalid, invalid -> nil
; valid -> the new state
(defun move-up (state x y next)
	; set object after move
	(let* ((object (get-square state (- y 1) x)))
	(cond
	  	; check valid state after move
		((isWall object) nil)
		((isBlank object) (set-square (set-square state x y next) x (- y 1) keeper) )
		((isStar object) (set-square (set-square state x y next) x (- y 1) keeperstar) )
		; additional check for box
		((isBox object)
			(let* ((upper (get-square state (- y 2) x)))
			(cond
				((or (isWall upper) (isBox upper) (isBoxStar upper)) nil)
				((isBlank upper) (set-square (set-square (set-square state x y next) x (- y 1) keeper) x (- y 2) box))
				((isStar upper) (set-square (set-square (set-square state x y next) x (- y 1) keeper) x (- y 2) boxstar))
			)
			)
		)
		; additional for box-star
		((isBoxStar object)
			(let* ((upper (get-square state (- y 2) x)))
			(cond
				((or (isWall upper) (isBox upper) (isBoxStar upper)) nil)
				; if upper square is blank, blank -> box and boxstar -> keeperstar
				((isBlank upper) (set-square (set-square (set-square state x y next) x (- y 1) keeperstar) x (- y 2) box))
				; if upper square is star, star -> boxstar and boxstar -> keeperstar
				((isStar upper) (set-square (set-square (set-square state x y next) x (- y 1) keeperstar) x (- y 2) boxstar))
			)
			)
		)
	)
	)
)
; helper funtion for try-move
; move down 1 pos for keeper, same as move-up
(defun move-down (state x y next)
	; object is down position after move
	(let* ((object (get-square state (+ y 1) x)))
	(cond
		((isWall object) nil)
		((isBlank object) (set-square (set-square state x y next) x (+ y 1) keeper))
		((isStar object) (set-square (set-square state x y next) x (+ y 1) keeperstar))
		((isBox object)
			(let* ((down (get-square state (+ y 2) x)))

			(cond
				((or (isWall down) (isBox down) (isBoxStar down)) nil)
				((isBlank down) (set-square (set-square (set-square state x y next) x (+ y 1) keeper) x (+ y 2) box))
				((isStar down) (set-square (set-square (set-square state x y next) x (+ y 1) keeper) x (+ y 2) boxstar))
			)
			)
		)
		((isBoxStar object)
			(let* ((down (get-square state (+ y 2) x)))
			(cond
				((or (isWall down) (isBox down) (isBoxStar down)) nil)
				; if down square is blank, blank -> box and boxstar -> keeperstar
				((isBlank down) (set-square (set-square (set-square state x y next) x (+ y 1) keeperstar) x (+ y 2) box))
				; if down square is star, star -> boxstar and boxstar -> keeperstar
				((isStar down) (set-square (set-square (set-square state x y next) x (+ y 1) keeperstar) x (+ y 2) boxstar))
			)
			)
		)
	)
	)
)

; helper funtion for try-move
; move keeper to the left by 1 step
; same as move-up
(defun move-left (state x y next)
	(let* ((object (get-square state y (- x 1))))
	(cond
		((isWall object) nil)
		((isBlank object) (set-square (set-square state x y next) (- x 1) y keeper))
		((isStar object) (set-square (set-square state x y next) (- x 1) y keeperstar))
		((isBox object)
			(let* ((left (get-square state y (- x 2))))
			(cond
				((or (isWall left) (isBox left) (isBoxStar left)) nil)
				((isBlank left) (set-square (set-square (set-square state x y next) (- x 1) y keeper) (- x 2) y box))
				((isStar left) (set-square (set-square (set-square state x y next) (- x 1) y keeper) (- x 2) y boxstar))
			)
			)
		)
		((isBoxStar object)
			(let* ((left (get-square state y (- x 2))))
			(cond
				((or (isWall left) (isBox left) (isBoxStar left)) nil)
				; if left square is blank, blank -> box and boxstar -> keeperstar
				((isBlank left) (set-square (set-square (set-square state x y next) (- x 1) y keeperstar) (- x 2) y box))
				; if left square is star, star -> boxstar and boxstar -> keeperstar
				((isStar left) (set-square (set-square (set-square state x y next) (- x 1) y keeperstar) (- x 2) y boxstar))
			)
			)
		)
	)
	)
)

; helper funtion for try-move
; move keeper to right by 1 step
; same as move-up
(defun move-right (state x y next)
	(let* ((object (get-square state y (+ x 1))))
	(cond
	  	; set the state after move
		((isWall object) nil)
		((isBlank object) (set-square (set-square state x y next) (+ x 1) y keeper))
		((isStar object) (set-square (set-square state x y next) (+ x 1) y keeperstar))
		; additional for box
		((isBox object)
			(let* ((right (get-square state y (+ x 2))))
			(cond
				((or (isWall right) (isBox right) (isBoxStar right)) nil)
				; if right square is blank, blank -> box and boxstar -> keeperstar
				((isBlank right) (set-square (set-square (set-square state x y next) (+ x 1) y keeper) (+ x 2) y box))
				; if right square is star, star -> boxstar and boxstar -> keeperstar
				((isStar right) (set-square (set-square (set-square state x y next) (+ x 1) y keeper) (+ x 2) y boxstar))
			)
			)
		)
		((isBoxStar object)
			(let* ((right (get-square state y (+ x 2))))
			(cond
				((or (isWall right) (isBox right) (isBoxStar right)) nil)
				; if rightsquare is blank, blank -> box and boxstar -> keeperstar
				((isBlank right) (set-square (set-square (set-square state x y next) (+ x 1) y keeperstar) (+ x 2) y box))
				; if rightsquare is star, star -> boxstar and boxstar -> keeperstar
				((isStar right) (set-square (set-square (set-square state x y next) (+ x 1) y keeperstar) (+ x 2) y boxstar))
			)
			)
		)
	)
	)
)
; helper funtion for try-move
; return the expected state after the keeper move
(defun expect-state (state)
	(cond
		; if the square is keeper, it becomes blank after move
		((isKeeper state) blank)
		; if the square is keeperstar, it becomes star after move
		((isKeeperStar state) star)
	)
)

; helper function for next-states
; The function takes in a state and a move direction
; the state after we move in a certain direction by move-up,down,left,right
; invalid state gives nil
(defun try-move (state direction)
	(let* ((pos (getKeeperPosition state 0))
	(col (car pos))
	(row (cadr pos))
	(square (get-square state row col))
	(next (expect-state square))
	)
	; state is the content of keeper's square
	(cond
		((equal direction 'UP) (move-up state col row next))
		((equal direction 'DOWN) (move-down state col row next))
		((equal direction 'LEFT) (move-left state col row next))
		((equal direction 'RIGHT) (move-right state col row next))
		(t nil)
	)
	)
)

; as instruction
(defun next-states (s)
  (let* ((pos (getKeeperPosition s 0))
	 (x (car pos))
	 (y (cadr pos))
	 (result  (list (try-move s 'UP) (try-move s 'DOWN) (try-move s 'LEFT) (try-move s 'RIGHT)))
	 )
    (cleanUpList result);end
   );end let
  );

; EXERCISE: Modify this function to compute the trivial 
; admissible heuristic.
;
(defun h0 (s)
  0
  )

; EXERCISE: Modify this function to compute the 
; number of misplaced boxes in s.
;
(defun h1 (s)
  (cond 
    ; if empty input, returns 0
    ((null s) 0)
    ; if s is an atom
    ((atom s) 
     (cond
       ; if s is a box, return 1 representing one misplaced box is found
       ((isBox s) 1)
       ; otherwise returns 0, no misplaced box
       (t 0)
       )
     )
    ; add up the values of squares
    (t (+ (h1 (car s)) (h1 (cdr s))))
    )
  )
; EXERCISE: Change the name of this function to h<UID> where
; <UID> is your actual student ID number. Then, modify this 
; function to compute an admissible heuristic value of s. 
; 
; This function will be entered in the competition.
; Objective: make A* solve problems as fast as possible.
; The Lisp 'time' function can be used to measure the 
; running time of a function call.
;
; helper function for h104756697
; The function takes two numbers
; calculate the absolute value of a-b
(defun absolute-divide (a b)
	(cond
		((> a b) (- a b))
		(t (- b a))
	)
)

; helper function for h104756697
; The function calculate mahanttan distance between two points
(defun calculate-manhattan (a b)
	(cond
		((or (null a) (null b)) 0)
		(t (+ (absolute-divide (car a) (car b)) (absolute-divide (cadr a) (cadr b))))
	)
)

; helper function for h104756697
; return the minimum manhattan distance in the give list l from point p
(defun calculate-least-manhattan (p l)
	(cond
		((or (null p) (null l)) nil)
		(t 
			(let* ((minimum (calculate-least-manhattan p (cdr l))))
				(cond
					; end, compare distance betwween p and last element
					((null minimum) (calculate-manhattan p (car l)))
					; otherwise, compare minimum value with current element
					(t (min (calculate-manhattan p (car l)) minimum))
				)
			)
		)
	 )
)

; helper function for h104756697
; The function takes in a list of boxes, and a list of goals
; calculate the total distance between all those box and goals
(defun total-distance (box goals)
	(cond
		((or (null box) (null goals)) 0)
		(t 
			(+ (calculate-least-manhattan (car box) goals) (total-distance (cdr box) goals))
		)
	)
)

; The function takes in a state and a box
; check if a certain box is in corner
(defun is-corner (state box)
	(cond
		((null box) nil)
		(t 
			(let* ((pos (car box)) (r (car pos)) (c (cadr pos))
				(up (get-square state (- r 1) c)) (down (get-square state (+ r 1) c))
				(left (get-square state r (- c 1))) (right (get-square state r (+ c 1)))
			 )
			 (cond
			  	; check its pos by 4 corner settings
				((and (isWall right) (isWall up)) t)
				((and (isWall right) (isWall down)) t)
				((and (isWall left) (isWall up)) t)
				((and (isWall left) (isWall down)) t)
				(t (is-corner state (cdr box)))
			 )
			) 
		)
	)	

)

; The function takes in a state
; check if any box is in the corner
(defun check-corner-box (state)
	(cond
		((null state) nil)
		(t (is-corner state (getBoxPosition state 0)))
	)
)

; The function takes in a state
; check if the game is dead, at least 1 box is in corner
(defun isOver (state)
	(cond
		((or (check-corner-box state)) t)
		(t nil)
	)
)

; helper funtion of getStarPosition
(defun getStarColumn (row x y)
  (cond ((null row) nil)
    (t (if (or (isStar (car row)) (isKeeperStar (car row)) (isBoxStar (car row)))
      	(append (list (list x y)) (getStarColumn (cdr row) x (+ y 1)))
      	(getStarColumn (cdr row) x (+ y 1))
      ));end if
    );end if
  );end defun

; same as get keeper positioin, but return a list
(defun getStarPosition (state row)
  (cond ((null state) nil)
    (t (let* ((x (getStarColumn (car state) row 0)))
      	(append x (getStarPosition (cdr state) (+ row 1)))
      ));end let
    );end if
  );end defun

; helper funtion of getBoxPosition
(defun getBoxColumn (row x y)
  (cond ((null row) nil)
    (t (if (isBox (car row))
      	(append (list (list x y)) (getBoxColumn (cdr row) x (+ y 1)))
      	(getBoxColumn (cdr row) x (+ y 1))
      ));end if
    );end if
  );end defun

; same as get keeper positioin, but return a list
(defun getBoxPosition (state row)
  (cond ((null state) nil)
    (t (let* ((x (getBoxColumn (car state) row 0)))
      	(append x (getBoxPosition (cdr state) (+ row 1)))
      ));end let
    );end if
  );end defun

; EXERCISE: Change the name of this function to h<UID> where
; <UID> is your actual student ID number. Then, modify this 
; function to compute an admissible heuristic value of s. 
; 
; This function will be entered in the competition.
; Objective: make A* solve problems as fast as possible.
; The Lisp 'time' function can be used to measure the 
; running time of a function call.
;
; The heuristic is to use the sum of the total Manhattan distance between 
; each box to its nearest star. 
; It turns out very bad in simple cases (way worst than h1 because it takes long 
; to scan the whole map again and again). 
; Later, I realized that the major waste is that the keeper spent too much time on 
; dead cases (no possible solutions).
; So, the program first detect whether a state is dead or not
; If it is dead, I just assign a large value to it so it will never be expaneded.
; Otherwise, return h1.
; The performance turns out to be very good 
; The deadcases are yet not fully done, since some cases are way too complicated
; to implement within one week.
(defun h104756697 (s)
  (cond
    ((isOver s) 1000)
    (t (total-distance (getBoxPosition s 0) (getStarPosition s 0)))
    )
  )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#|
 | Some predefined problems.
 | Each problem can be visualized by calling (printstate <problem>). For example, (printstate p1).
 | Problems are roughly ordered by their difficulties.
 | For most problems, we also privide 2 additional number per problem:
 |    1) # of nodes expanded by A* using our next-states and h0 heuristic.
 |    2) the depth of the optimal solution.
 | These numbers are located at the comments of the problems. For example, the first problem below 
 | was solved by 80 nodes expansion of A* and its optimal solution depth is 7.
 | 
 | Your implementation may not result in the same number of nodes expanded, but it should probably
 | give something in the same ballpark. As for the solution depth, any admissible heuristic must 
 | make A* return an optimal solution. So, the depths of the optimal solutions provided could be used
 | for checking whether your heuristic is admissible.
 |
 | Warning: some problems toward the end are quite hard and could be impossible to solve without a good heuristic!
 | 
 |#

;(80,7)
(setq p1 '((1 1 1 1 1 1)
	   (1 0 3 0 0 1)
	   (1 0 2 0 0 1)
	   (1 1 0 1 1 1)
	   (1 0 0 0 0 1)
	   (1 0 0 0 4 1)
	   (1 1 1 1 1 1)))

;(110,10)
(setq p2 '((1 1 1 1 1 1 1)
	   (1 0 0 0 0 0 1) 
	   (1 0 0 0 0 0 1) 
	   (1 0 0 2 1 4 1) 
	   (1 3 0 0 1 0 1)
	   (1 1 1 1 1 1 1)))

;(211,12)
(setq p3 '((1 1 1 1 1 1 1 1 1)
	   (1 0 0 0 1 0 0 0 1)
	   (1 0 0 0 2 0 3 4 1)
	   (1 0 0 0 1 0 0 0 1)
	   (1 0 0 0 1 0 0 0 1)
	   (1 1 1 1 1 1 1 1 1)))

;(300,13)
(setq p4 '((1 1 1 1 1 1 1)
	   (0 0 0 0 0 1 4)
	   (0 0 0 0 0 0 0)
	   (0 0 1 1 1 0 0)
	   (0 0 1 0 0 0 0)
	   (0 2 1 0 0 0 0)
	   (0 3 1 0 0 0 0)))

;(551,10)
(setq p5 '((1 1 1 1 1 1)
	   (1 1 0 0 1 1)
	   (1 0 0 0 0 1)
	   (1 4 2 2 4 1)
	   (1 0 0 0 0 1)
	   (1 1 3 1 1 1)
	   (1 1 1 1 1 1)))

;(722,12)
(setq p6 '((1 1 1 1 1 1 1 1)
	   (1 0 0 0 0 0 4 1)
	   (1 0 0 0 2 2 3 1)
	   (1 0 0 1 0 0 4 1)
	   (1 1 1 1 1 1 1 1)))

;(1738,50)
(setq p7 '((1 1 1 1 1 1 1 1 1 1)
	   (0 0 1 1 1 1 0 0 0 3)
	   (0 0 0 0 0 1 0 0 0 0)
	   (0 0 0 0 0 1 0 0 1 0)
	   (0 0 1 0 0 1 0 0 1 0)
	   (0 2 1 0 0 0 0 0 1 0)
	   (0 0 1 0 0 0 0 0 1 4)))

;(1763,22)
(setq p8 '((1 1 1 1 1 1)
	   (1 4 0 0 4 1)
	   (1 0 2 2 0 1)
	   (1 2 0 1 0 1)
	   (1 3 0 0 4 1)
	   (1 1 1 1 1 1)))

;(1806,41)
(setq p9 '((1 1 1 1 1 1 1 1 1) 
	   (1 1 1 0 0 1 1 1 1) 
	   (1 0 0 0 0 0 2 0 1) 
	   (1 0 1 0 0 1 2 0 1) 
	   (1 0 4 0 4 1 3 0 1) 
	   (1 1 1 1 1 1 1 1 1)))

;(10082,51)
(setq p10 '((1 1 1 1 1 0 0)
	    (1 0 0 0 1 1 0)
	    (1 3 2 0 0 1 1)
	    (1 1 0 2 0 0 1)
	    (0 1 1 0 2 0 1)
	    (0 0 1 1 0 0 1)
	    (0 0 0 1 1 4 1)
	    (0 0 0 0 1 4 1)
	    (0 0 0 0 1 4 1)
	    (0 0 0 0 1 1 1)))

;(16517,48)
(setq p11 '((1 1 1 1 1 1 1)
	    (1 4 0 0 0 4 1)
	    (1 0 2 2 1 0 1)
	    (1 0 2 0 1 3 1)
	    (1 1 2 0 1 0 1)
	    (1 4 0 0 4 0 1)
	    (1 1 1 1 1 1 1)))

;(22035,38)
(setq p12 '((0 0 0 0 1 1 1 1 1 0 0 0)
	    (1 1 1 1 1 0 0 0 1 1 1 1)
	    (1 0 0 0 2 0 0 0 0 0 0 1)
	    (1 3 0 0 0 0 0 0 0 0 0 1)
	    (1 0 0 0 2 1 1 1 0 0 0 1)
	    (1 0 0 0 0 1 0 1 4 0 4 1)
	    (1 1 1 1 1 1 0 1 1 1 1 1)))

;(26905,28)
(setq p13 '((1 1 1 1 1 1 1 1 1 1)
	    (1 4 0 0 0 0 0 2 0 1)
	    (1 0 2 0 0 0 0 0 4 1)
	    (1 0 3 0 0 0 0 0 2 1)
	    (1 0 0 0 0 0 0 0 0 1)
	    (1 0 0 0 0 0 0 0 4 1)
	    (1 1 1 1 1 1 1 1 1 1)))

;(41715,53)
(setq p14 '((0 0 1 0 0 0 0)
	    (0 2 1 4 0 0 0)
	    (0 2 0 4 0 0 0)	   
	    (3 2 1 1 1 0 0)
	    (0 0 1 4 0 0 0)))

;(48695,44)
(setq p15 '((1 1 1 1 1 1 1)
	    (1 0 0 0 0 0 1)
	    (1 0 0 2 2 0 1)
	    (1 0 2 0 2 3 1)
	    (1 4 4 1 1 1 1)
	    (1 4 4 1 0 0 0)
	    (1 1 1 1 0 0 0)
	    ))

;(91344,111)
(setq p16 '((1 1 1 1 1 0 0 0)
	    (1 0 0 0 1 0 0 0)
	    (1 2 1 0 1 1 1 1)
	    (1 4 0 0 0 0 0 1)
	    (1 0 0 5 0 5 0 1)
	    (1 0 5 0 1 0 1 1)
	    (1 1 1 0 3 0 1 0)
	    (0 0 1 1 1 1 1 0)))

;(3301278,76)
(setq p17 '((1 1 1 1 1 1 1 1 1 1)
	    (1 3 0 0 1 0 0 0 4 1)
	    (1 0 2 0 2 0 0 4 4 1)
	    (1 0 2 2 2 1 1 4 4 1)
	    (1 0 0 0 0 1 1 4 4 1)
	    (1 1 1 1 1 1 0 0 0 0)))

;(??,25)
(setq p18 '((0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0)
	    (0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0)
	    (1 1 1 1 1 0 0 0 0 0 0 1 1 1 1 1)
	    (0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0)
	    (0 0 0 0 0 0 1 0 0 1 0 0 0 0 0 0)
	    (0 0 0 0 0 0 0 0 3 0 0 0 0 0 0 0)
	    (0 0 0 0 0 0 1 0 0 1 0 0 0 0 0 0)
	    (0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0)
	    (1 1 1 1 1 0 0 0 0 0 0 1 1 1 1 1)
	    (0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0)
	    (0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0)
	    (0 0 0 0 1 0 0 0 0 0 4 1 0 0 0 0)
	    (0 0 0 0 1 0 2 0 0 0 0 1 0 0 0 0)	    
	    (0 0 0 0 1 0 2 0 0 0 4 1 0 0 0 0)
	    ))
;(??,21)
(setq p19 '((0 0 0 1 0 0 0 0 1 0 0 0)
	    (0 0 0 1 0 0 0 0 1 0 0 0)
	    (0 0 0 1 0 0 0 0 1 0 0 0)
	    (1 1 1 1 0 0 0 0 1 1 1 1)
	    (0 0 0 0 1 0 0 1 0 0 0 0)
	    (0 0 0 0 0 0 3 0 0 0 2 0)
	    (0 0 0 0 1 0 0 1 0 0 0 4)
	    (1 1 1 1 0 0 0 0 1 1 1 1)
	    (0 0 0 1 0 0 0 0 1 0 0 0)
	    (0 0 0 1 0 0 0 0 1 0 0 0)
	    (0 0 0 1 0 2 0 4 1 0 0 0)))

;(??,??)
(setq p20 '((0 0 0 1 1 1 1 0 0)
	    (1 1 1 1 0 0 1 1 0)
	    (1 0 0 0 2 0 0 1 0)
	    (1 0 0 5 5 5 0 1 0)
	    (1 0 0 4 0 4 0 1 1)
	    (1 1 0 5 0 5 0 0 1)
	    (0 1 1 5 5 5 0 0 1)
	    (0 0 1 0 2 0 1 1 1)
	    (0 0 1 0 3 0 1 0 0)
	    (0 0 1 1 1 1 1 0 0)))

;(??,??)
(setq p21 '((0 0 1 1 1 1 1 1 1 0)
	    (1 1 1 0 0 1 1 1 1 0)
	    (1 0 0 2 0 0 0 1 1 0)
	    (1 3 2 0 2 0 0 0 1 0)
	    (1 1 0 2 0 2 0 0 1 0)
	    (0 1 1 0 2 0 2 0 1 0)
	    (0 0 1 1 0 2 0 0 1 0)
	    (0 0 0 1 1 1 1 0 1 0)
	    (0 0 0 0 1 4 1 0 0 1)
	    (0 0 0 0 1 4 4 4 0 1)
	    (0 0 0 0 1 0 1 4 0 1)
	    (0 0 0 0 1 4 4 4 0 1)
	    (0 0 0 0 1 1 1 1 1 1)))

;(??,??)
(setq p22 '((0 0 0 0 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0)
	    (0 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0 0 0)
	    (0 0 0 0 1 2 0 0 1 0 0 0 0 0 0 0 0 0 0)
	    (0 0 1 1 1 0 0 2 1 1 0 0 0 0 0 0 0 0 0)
	    (0 0 1 0 0 2 0 2 0 1 0 0 0 0 0 0 0 0 0)
	    (1 1 1 0 1 0 1 1 0 1 0 0 0 1 1 1 1 1 1)
	    (1 0 0 0 1 0 1 1 0 1 1 1 1 1 0 0 4 4 1)
	    (1 0 2 0 0 2 0 0 0 0 0 0 0 0 0 0 4 4 1)
	    (1 1 1 1 1 0 1 1 1 0 1 3 1 1 0 0 4 4 1)
	    (0 0 0 0 1 0 0 0 0 0 1 1 1 1 1 1 1 1 1)
	    (0 0 0 0 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#|
 | Utility functions for printing states and moves.
 | You do not need to understand any of the functions below this point.
 |#

;
; helper function of prettyMoves
; from s1 --> s2
;
(defun detectDiff (s1 s2)
  (let* ((k1 (getKeeperPosition s1 0))
	 (k2 (getKeeperPosition s2 0))
	 (deltaX (- (car k2) (car k1)))
	 (deltaY (- (cadr k2) (cadr k1)))
	 )
    (cond ((= deltaX 0) (if (> deltaY 0) 'DOWN 'UP))
	  (t (if (> deltaX 0) 'RIGHT 'LEFT))
	  );end cond
    );end let
  );end defun

;
; Translates a list of states into a list of moves.
; Usage: (prettyMoves (a* <problem> #'goal-test #'next-states #'heuristic))
;
(defun prettyMoves (m)
  (cond ((null m) nil)
	((= 1 (length m)) (list 'END))
	(t (cons (detectDiff (car m) (cadr m)) (prettyMoves (cdr m))))
	);end cond
  );

;
; Print the content of the square to stdout.
;
(defun printSquare (s)
  (cond ((= s blank) (format t " "))
	((= s wall) (format t "#"))
	((= s box) (format t "$"))
	((= s keeper) (format t "@"))
	((= s star) (format t "."))
	((= s boxstar) (format t "*"))
	((= s keeperstar) (format t "+"))
	(t (format t "|"))
	);end cond
  )

;
; Print a row
;
(defun printRow (r)
  (dolist (cur r)
    (printSquare cur)    
    )
  );

;
; Print a state
;
(defun printState (s)
  (progn    
    (dolist (cur s)
      (printRow cur)
      (format t "~%")
      )
    );end progn
  )

;
; Print a list of states with delay.
;
(defun printStates (sl delay)
  (dolist (cur sl)
    (printState cur)
    (sleep delay)
    );end dolist
  );end defun

(setq s1 '((1 1 1 1 1)(1 0 0 4 1)
(1 0 2 0 1)
(1 0 3 0 1)
(1 0 0 0 1)
(1 1 1 1 1)
))
(print (next-states s1))

(setq s2 '((1 1 1 1 1)
(1 0 0 4 1)
(1 0 2 3 1)
(1 0 0 0 1)
(1 0 0 0 1)
(1 1 1 1 1)
))
(print (next-states s2))

(setq s3 '((1 1 1 1 1)
(1 0 0 6 1)
(1 0 2 0 1)
(1 0 0 0 1)
(1 0 0 0 1)
(1 1 1 1 1)
))
(print (next-states s3))
(setq s4 '((1 1 1 1 1)
(1 4 2 0 1)
(1 0 0 0 1)
(1 0 0 0 1)
(1 0 5 3 1)
(1 1 1 1 1)
))
(print (next-states s4))


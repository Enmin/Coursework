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
; Helper function of getKeeperPosition
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
  ((atom s) (not (isBox s)))
  ((null s) t)
  (t (and (goal-test(car s)) (goal-test (cdr s))))
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
; Helper function for get-square
; The function takes in a state S, a row number r
; Return the rth row content of state S
; It the square is outside the scope, return nil
(defun get-row (S r)
	(cond
		; if r < 0, return 1
		((< r 0) nil)
		; if S is empty, return 1
		((null S) nil)
		; if r is 0, then the row is found
		((= r 0) (car S))
		; otherwise, keep searching rows
		(t (get-row (cdr S) (- r 1)))
	)
)

; Helper function for get-square
; The function takes in a row S, a column number c
; Return the cth column content of S
; It the square is outside the scope, return 1
(defun get-content (S c)
	(cond
		; if S is empty, return 1
		((null S) 1)
		; if c < 0, return 1
		((< c 0) 1)
		; if c == 0, square is found
		((= c 0) (car S))
		; otherwise, keep searching columns
		(t (get-content (cdr S) (- c 1)))
	)
)

; Helper function for TRY-MOVE
; The function takes in a state S, a row number r, a column number c.
; Return the integer content of state S at square (r, c).
; If the square is outside the scope of the problem, return the value of a wall (1).
(defun get-square (S r c)
	(get-content (get-row S r) c)
)

; Helper function for SET-SQUARE
; The function takes in a row S, a column number c, and a square content c(integer)
; Returns a new state S that is obtained by setting the cth column to value v
(defun set-row (S c v)
	(cond
		((null S) nil)
		((= c 0) (cons v (set-row (cdr S) (- c 1) v)))
		(t (cons (car S) (set-row (cdr S) (- c 1) v)))
	)
)

; Helper function for TRY-MOVE
; The function takes in a state S, a row number r, a column number c, and a square content v(integer)
; Returns a new state S' that is obtain by setting the square (r, c) to value v
(defun set-square (S c r v)
	(cond
		((null S) nil)
		((= r 0) (cons (set-row (car S) c v) (set-square (cdr S) c (- r 1) v)))
		(t (cons (car S) (set-square (cdr S) c (- r 1) v)))
	)
)

; Helper funtion for try-move
; The function takes in a state S and keeper's position x and y
; Returns the state that is the result of moving the keepr up in state S
; nil is returned if the move is invalid
(defun move-up (S x y next)
	; neighbor is the up square
	(let* ((neighbor (get-square S (- y 1) x)))
	(cond
		; up square is wall, invalid move
		((isWall neighbor) nil)
		; up square is blank, it becomes keeper after move
		((isBlank neighbor) (set-square (set-square S x y next) x (- y 1) keeper) )
		; up square is star, it becomes keeperstar after move
		((isStar neighbor) (set-square (set-square S x y next) x (- y 1) keeperstar) )
		; up square is box, we need to further check the upper square
		((isBox neighbor)
			(let* ((upper (get-square S (- y 2) x)))
			(cond
				; if upper square is wall or box or boxstar, invalid move
				((or (isWall upper) (isBox upper) (isBoxStar upper)) nil)
				; if upper square is blank, it becomes box and box becomes keeper after move
				((isBlank upper) (set-square (set-square (set-square S x y next) x (- y 1) keeper) x (- y 2) box))
				; if upper square is star, it becomes boxstar and box becomes keeper after move
				((isStar upper) (set-square (set-square (set-square S x y next) x (- y 1) keeper) x (- y 2) boxstar))
			)
			)
		)
		; up square is boxstar, we need to further check the upper square
		((isBoxStar neighbor)
			(let* ((upper (get-square S (- y 2) x)))
			(cond
				; if upper square is wall or box or boxstar, invalid move
				((or (isWall upper) (isBox upper) (isBoxStar upper)) nil)
				; if upper square is blank, it becomes box and box becomes keeper after move
				((isBlank upper) (set-square (set-square (set-square S x y next) x (- y 1) keeperstar) x (- y 2) box))
				; if upper square is star, it becomes boxstar and box becomes keeper after move
				((isStar upper) (set-square (set-square (set-square S x y next) x (- y 1) keeperstar) x (- y 2) boxstar))
			)
			)
		)
	)
	)
)
; Helper funtion for try-move
; The function takes in a state S and keeper's position x and y
; Returns the state that is the result of moving the keepr down in state S
; nil is returned if the move is invalid
(defun move-down (S x y next)
	; neighbor is the up square
	(let* ((neighbor (get-square S (+ y 1) x)))
	(cond
		; up square is wall, invalid move
		((isWall neighbor) nil)
		; up square is blank, it becomes keeper after move
		((isBlank neighbor) (set-square (set-square S x y next) x (+ y 1) keeper))
		; up square is star, it becomes keeperstar after move
		((isStar neighbor) (set-square (set-square S x y next) x (+ y 1) keeperstar))
		; up square is box, we need to further check the upper square
		((isBox neighbor)
			(let* ((down (get-square S (+ y 2) x)))

			(cond
				; if upper square is wall or box or boxstar, invalid move
				((or (isWall down) (isBox down) (isBoxStar down)) nil)
				; if down square is blank, it becomes box and box becomes keeper after move
				((isBlank down) (set-square (set-square (set-square S x y next) x (+ y 1) keeper) x (+ y 2) box))
				; if down square is star, it becomes boxstar and box becomes keeper after move
				((isStar down) (set-square (set-square (set-square S x y next) x (+ y 1) keeper) x (+ y 2) boxstar))
			)
			)
		)
		; up square is boxstar, we need to further check the down square
		((isBoxStar neighbor)
			(let* ((down (get-square S (+ y 2) x)))
			(cond
				; if down square is wall or box or boxstar, invalid move
				((or (isWall down) (isBox down) (isBoxStar down)) nil)
				; if down square is blank, it becomes box and box becomes keeper after move
				((isBlank down) (set-square (set-square (set-square S x y next) x (+ y 1) keeperstar) x (+ y 2) box))
				; if down square is star, it becomes boxstar and box becomes keeper after move
				((isStar down) (set-square (set-square (set-square S x y next) x (+ y 1) keeperstar) x (+ y 2) boxstar))
			)
			)
		)
	)
	)
)

; Helper funtion for try-move
; The function takes in a state S and keeper's position x and y
; Returns the state that is the result of moving the keepr left in state S
; nil is returned if the move is invalid
(defun move-left (S x y next)
	; neighbor is the up square
	(let* ((neighbor (get-square S y (- x 1))))
	(cond
		; up square is wall, invalid move
		((isWall neighbor) nil)
		; up square is blank, it becomes keeper after move
		((isBlank neighbor) (set-square (set-square S x y next) (- x 1) y keeper))
		; up square is star, it becomes keeperstar after move
		((isStar neighbor) (set-square (set-square S x y next) (- x 1) y keeperstar))
		; up square is box, we need to further check the left square
		((isBox neighbor)
			(let* ((left (get-square S y (- x 2))))
			(cond
				; if left square is wall or box or boxstar, invalid move
				((or (isWall left) (isBox left) (isBoxStar left)) nil)
				; if left square is blank, it becomes box and box becomes keeper after move
				((isBlank left) (set-square (set-square (set-square S x y next) (- x 1) y keeper) (- x 2) y box))
				; if left square is star, it becomes boxstar and box becomes keeper after move
				((isStar left) (set-square (set-square (set-square S x y next) (- x 1) y keeper) (- x 2) y boxstar))
			)
			)
		)
		; up square is boxstar, we need to further check the left square
		((isBoxStar neighbor)
			(let* ((left (get-square S y (- x 2))))
			(cond
				; if left square is wall or box or boxstar, invalid move
				((or (isWall left) (isBox left) (isBoxStar left)) nil)
				; if left square is blank, it becomes box and box becomes keeper after move
				((isBlank left) (set-square (set-square (set-square S x y next) (- x 1) y keeperstar) (- x 2) y box))
				; if left square is star, it becomes boxstar and box becomes keeper after move
				((isStar left) (set-square (set-square (set-square S x y next) (- x 1) y keeperstar) (- x 2) y boxstar))
			)
			)
		)
	)
	)
)

; Helper funtion for try-move
; The function takes in a state S and keeper's position x and y
; Returns the state that is the result of moving the keepr right in state S
; nil is returned if the move is invalid
(defun move-right (S x y next)
	; neighbor is the up square
	(let* ((neighbor (get-square S y (+ x 1))))
	(cond
		; up square is wall, invalid move
		((isWall neighbor) nil)
		; up square is blank, it becomes keeper after move
		((isBlank neighbor) (set-square (set-square S x y next) (+ x 1) y keeper))
		; up square is star, it becomes keeperstar after move
		((isStar neighbor) (set-square (set-square S x y next) (+ x 1) y keeperstar))
		; up square is box, we need to further check the right square
		((isBox neighbor)
			(let* ((right (get-square S y (+ x 2))))
			(cond
				; if right square is wall or box or boxstar, invalid move
				((or (isWall right) (isBox right) (isBoxStar right)) nil)
				; if right square is blank, it becomes box and box becomes keeper after move
				((isBlank right) (set-square (set-square (set-square S x y next) (+ x 1) y keeper) (+ x 2) y box))
				; if right square is star, it becomes boxstar and box becomes keeper after move
				((isStar right) (set-square (set-square (set-square S x y next) (+ x 1) y keeper) (+ x 2) y boxstar))
			)
			)
		)
		; up square is boxstar, we need to further check the right square
		((isBoxStar neighbor)
			(let* ((right (get-square S y (+ x 2))))
			(cond
				; if right square is wall or box or boxstar, invalid move
				((or (isWall right) (isBox right) (isBoxStar right)) nil)
				; if right square is blank, it becomes box and box becomes keeper after move
				((isBlank right) (set-square (set-square (set-square S x y next) (+ x 1) y keeperstar) (+ x 2) y box))
				; if right square is star, it becomes boxstar and box becomes keeper after move
				((isStar right) (set-square (set-square (set-square S x y next) (+ x 1) y keeperstar) (+ x 2) y boxstar))
			)
			)
		)
	)
	)
)
; Helper funtion for try-move
; The funtion takes in the current state of keeper
; Returns the next state of keeper if s/he moves
(defun if-move (state)
	(cond
		; if the square is keeper, it becomes blank after move
		((isKeeper state) blank)
		; if the square is keeperstar, it becomes star after move
		((isKeeperStar state) star)
	)
)

; Helper function for NEXT-STATES
; The function takes in a state S and a move direction D.
; Returns the state that is the result of moving the keeper in state S in direction D.
; nil is returned if the move is invalid
(defun try-move (S D)
	(let* ((pos (getKeeperPosition S 0))
	(c (car pos))
	(r (cadr pos))
	(state (get-square S r c))
	(next (if-move state))
	)
	; state is the content of keeper's square
	(cond
		((equal D 'UP) (move-up S c r next))
		((equal D 'DOWN) (move-down S c r next))
		((equal D 'LEFT) (move-left S c r next))
		((equal D 'RIGHT) (move-right S c r next))
		(t nil)
	)
	)
)
(defun next-states (s)
  (let* ((pos (getKeeperPosition s 0))
	 (x (car pos))
	 (y (cadr pos))
	 ;x and y are now the coordinate of the keeper in s.
	 (result nil)
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
;; Helper function for h104844760
;; The function takes a number a, and a number b
;; Returns the absolute difference between a and b
(defun abs-diff (a b)
	(cond
		;; if a > b, return a - b
		((> a b) (- a b))
		;; otherwise, returns b - a
		(t (- b a))
	)
)

;; Helper function for h104844760
;; The function takes in a point a, and a point b
;; Returns the manhattan distance between a and b
(defun manhattan-distance (a b)
	(cond
		;; if empty input, return 0
		((or (null a) (null b)) 0)
		;; add up differences of rows and columns
		(t (+ (abs-diff (car a) (car b)) (abs-diff (cadr a) (cadr b))))
	)
)

;; Helper function for h104844760
;; The function takes in a point b, and a list of points g
;; Returns a list of manhatten distances from b to each point in g
(defun nearest-manhattan (b g)
	(cond
		;; if empty input, returns nil
		((or (null b) (null g)) nil)
		(t 
			;; minima represents current minimum value
			(let* ((minima (nearest-manhattan b (cdr g))))
				(cond
					;; if we are at the end of list, minima is 
					;; the distance between b and the last element in g
					((null minima) (manhattan-distance b (car g)))
					;; otherwise, compare minima with current distance
					(t (min (manhattan-distance b (car g)) minima))
				)
			)
		)
	 )
)

;; Helper function for h104844760
;; The function takes in a list of boxes, b, and a list of goals, g
;; Return the summation of mahattan distance
(defun sum-distance (b g)
	(cond
		;; if empty input, return 0
		((or (null b) (null g)) 0)
		(t 
			(let* ((first-man (nearest-manhattan (car b) g)) (rest-man (sum-distance (cdr b) g)))
			;; total distance is the first distance plus the total rest distance
			(+ first-man rest-man)
			)
		)
	)
)

;; The function takes in a state s, and a box
;; Returns if the box is in the corner
(defun check-in-corner (s b)
	(cond
		;; if empty input, return nil
		((null b) nil)
		(t 
			(let* ((pos (car b)) (r (car pos)) (c (cadr pos))
				(up (get-square s (- r 1) c)) (down (get-square s (+ r 1) c))
				(left (get-square s r (- c 1))) (right (get-square s r (+ c 1)))
			)
			(cond
				; left/up are wall
				((and (isWall left) (isWall up)) t)
				; left/down are wall
				((and (isWall left) (isWall down)) t)
				; right/up are wall
				((and (isWall right) (isWall up)) t)
				; right/down are wall
				((and (isWall right) (isWall down)) t)
				(t (check-in-corner s (cdr b)))
			)
			) 
		)
	)	

)

;; The function takes in a state, s
;; Returns wheter if any box in s is in corner
(defun in-corner (s)
	(cond
		;; if empty input, return nil
		((null s) nil)
		;; otherwise check if any box is in corner
		(t (check-in-corner s (getBoxPosition s 0)))
	)
)

;; The function takes in a state, s
;; Returns if the game is already dead
(defun isDead (s)
	(cond
		;; if a box is in corner, or is against a wall without star,
		;; or two boxes are adjcant and next to a wall ...
		;; the game is over
		((or (in-corner s)
			; (dead-wall s)
		) t)
		(t nil)
	)
)

;; Helper funtion of getStarPosition
(defun getStarColumn (r x y)
  (if (null r) nil
    (if (or (isStar (car r)) (isKeeperStar (car r)) (isBoxStar (car r)))
      (append (list (list x y)) (getStarColumn (cdr r) x (+ y 1)))
      (getStarColumn (cdr r) x (+ y 1))
      );end if
    );end if
  );end defun

;
; getStarPosition (s firstRow)
; Returns a list indicating the position of the Star (c r).
; 
; Assumes that the Star is in row >= firstRow.
; The top row is the zeroth row.
; The first (right) column is the zeroth column.
;
;; The idea is borrowed from provided function getKeeperPosition and getKeeperColumn
(defun getStarPosition (s row)
  (if (null s) nil
    (let* ((x (getStarColumn (car s) row 0)))
      (append x (getStarPosition (cdr s) (+ row 1)))
      );end let
    );end if
  );end defun


;; Helper funtion of getBoxPosition
(defun getBoxColumn (r x y)
  (if (null r) nil
    (if (isBox (car r))
      (append (list (list x y)) (getBoxColumn (cdr r) x (+ y 1)))
      (getBoxColumn (cdr r) x (+ y 1))
      );end if
    );end if
  );end defun
;
; getBoxPosition (s firstRow)
; Returns a list indicating the position of the Box (c r).
; 
; Assumes that the Box is in row >= firstRow.
; The top row is the zeroth row.
; The first (right) column is the zeroth column.
;
;; The idea is borrowed from provided function getKeeperPosition and getKeeperColumn
(defun getBoxPosition (s row)
  (if (null s) nil
    (let* ((x (getBoxColumn (car s) row 0)))
      (append x (getBoxPosition (cdr s) (+ row 1)))
      );end let
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
    ((isDead s) 1000)
    (t (sum-distance (getBoxPosition s 0) (getStarPosition s 0)))
    ; (t (h1 s))
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
; Helper function of prettyMoves
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

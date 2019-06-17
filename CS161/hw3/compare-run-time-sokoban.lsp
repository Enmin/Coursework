(load "hw3-backup.lsp")
(load-a-star)

(setq problemList
      (list NIL  p1  p2  p3  p4  p5  p6  p7  p8  p9
	    p10 p11 p12 p13 p14 p15 p16 p17 p18 p19
	    p20 p21 p22))

; put your heuristic function list here
(setq hList
      (list #'h0 #'h1 #'h104756697))

;(setq selected-p# (list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16))
(setq selected-p# (list 17 18 19))
(setq selected-h# (list 2 3 4 5))

(defun run-time (function)
  (let ((run-base (get-internal-run-time)))
    (time (funcall function))
    (/ (- (get-internal-run-time) run-base) internal-time-units-per-second)))

(loop for p# in selected-p#
      do (loop for h# in selected-h#
	       do (or
		   (format t "~%------p#~a, h#~a------~%" p# h#)
		   (with-open-file (str "run-time-log.txt"
					:direction :output
					:if-exists :append
					:if-does-not-exist :create)
				   (format str "~a,~a,~f~%"
					   p#
					   h#
					   (run-time (lambda () (sokoban (nth p# problemList) (nth h# hList)))))))))

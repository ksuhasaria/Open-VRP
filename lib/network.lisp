;;; Utilities for generating a distance table using a list of node coords.
;;; -----------------------------------------
;;; - distance (int int array)		- Expects two node-IDs and a dist-array
;;; - node-distance (<Node> <Node>)	- Calculates distance between two <Node> objects
;;; - node (<Problem> int)		- Returns <Node> given a <Problem> and a node-id
;;; - generate-dist-array (coord-list)	- Returns array of distances
;;; - new-node				- Macro that creates a <Node> according to input
(in-package :open-vrp.util)

(defun distance (i j dist-array)
  "Read from the distance-table with two indices."
  (when (= i j) (error 'same-origin-destination :from i :to j))
  (aref dist-array i j))

(defun distance-coords (x1 y1 x2 y2)
  "Calculates pythagoras distance"
  (flet ((square (x)
	   (* x x)))
    (sqrt (+ (square (- x1 x2)) (square (- y1 y2))))))

(defun distance-coord-pair (n1 n2)
   "Calculates distance given two coord pairs. Returns NIL if both coords are the same."
   (if (eql n1 n2)
       NIL
       (distance-coords (car n1) (cdr n1)
			(car n2) (cdr n2))))
	         
(defgeneric node-distance (node1 node2)
  (:method (node1 node) "Inputs are not two nodes.")
  (:documentation "Given two node objects, calculate and return their distance (Cartesian)."))

(defmethod node-distance ((n1 node) (n2 node))
  (when (= (node-id n1) (node-id n2)) (error 'same-origin-destination :from n1 :to n2))
  (let ((x1 (node-xcor n1)) (y1 (node-ycor n1))
	(x2 (node-xcor n2)) (y2 (node-ycor n2)))
    (distance-coords x1 y1 x2 y2)))

(defun get-array-row (array row-index)
  "Given a 2-dimenstional array and a row-index, return the row as a list"
  (loop for row to (1- (array-dimension array 0))
       collect (aref array row-index row)))

(defun generate-dist-array (coord-list)
  "Given a list of coord pairs, generate an array of distances."
  (let* ((size (length coord-list))
	 (dist-array (eval `(make-array '(,size ,size) :initial-element nil))))
    (map0-n #'(lambda (x)
		 (map0-n #'(lambda (y)
			     (setf (aref dist-array x y)
				   (distance-coord-pair (nth x coord-list)
							(nth y coord-list))))
			 (1- size)))
	     (1- size))
     dist-array))
     
;; ----------------------------------------

;; Accessor functions
;;--------------------------

(defmethod node ((prob problem) id)
  (aref (problem-network prob) id))

;; --------------------------------

;; Create Node macro
;; ------------------
(defmacro new-node (id xcor ycor &key demand start end duration)
  `(make-instance 'node :id ,id :xcor ,xcor :ycor ,ycor
		  ,@(when demand `(:demand ,demand))
		  ,@(when start `(:start ,start))
		  ,@(when end `(:end ,end))
		  ,@(when duration `(:duration ,duration))))
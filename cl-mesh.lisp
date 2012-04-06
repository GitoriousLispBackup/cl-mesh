;; Copyright (c) 2010, 2011, 2012 Raffael L. Mancini <raffael.mancini@hcl-club.lu>

;; This file is part of cl-mesh.

;; cl-mesh is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; cl-mesh is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with cl-mesh.  If not, see <http://www.gnu.org/licenses/>.

(in-package :cl-mesh)

;;
;; Vector
;;

(defun vector-z-compare (v1 v2)
  "Are v1 and v2 sorted in ascending z order?"
  (< (lm:z v1)
     (lm:z v2)))

(defun vector-hash (v)
  (floor (* (abs (+ (lm:x v) 2))
            (+ (abs (lm:y v)) 3))
            (abs (+ (lm:z v) 5))))

;;
;; Triangle
;;

(defclass triangle ()
  ((normal
    :initarg :normal
    :type lm:vector
    :accessor normal)
   (vertices
    :initarg :vertices
    :type list
    :accessor vertices)))

(defclass index-triangle ()
  ((normal
    :initarg :normal
    ;; :initform '()
    :type lm:vector
    :accessor normal)
   (vertex-ids
    :initarg :vertex-ids
    ;; :initform '()
    :type list
    :accessor vertex-ids))
  (:documentation "A triangle with a normal vector and a list of 3
  vertex ids"))

;;
;; Mesh
;;

(defclass mesh ()
  ((vertices
    :initarg :vertices
    :accessor vertices)
   (triangles
    :initarg :triangles
    :type vector
    :accessor triangles)))

(defun sort-triangles-z (mesh)
  "Sort the triangles of a mesh destructively in the order of
ascending minimal z values"
  (setf (triangles mesh)
	(sort (triangles mesh)
	      (lambda (t1 t2)
		(< (lm:z (vertex 0 t1 mesh))
		   (lm:z (vertex 0 t2 mesh)))))))

(sb-ext:define-hash-table-test lm:vector= vector-hash)

(defmethod vertex (idx (triangle index-triangle) mesh)
  "The vertex of number idx in a mesh"
  (elt
   (vertices mesh)
   (elt (vertex-ids triangle) idx)))

(defmethod vertex (idx (triangle triangle) mesh)
  (elt (vertices triangle) idx))

(defmethod sort-vertices-z ((triangle index-triangle) mesh)
  "Sort the vertices of a triangle in a mesh in the order of ascending
z values "
  (setf (vertex-ids triangle)
	(sort (vertex-ids triangle)
	      (lambda (id1 id2)
		(cl-mesh:vector-z-compare
		 (elt (vertices mesh) id1)
		 (elt (vertices mesh) id2))))))

(defmethod sort-vertices-z ((triangle triangle) mesh)
  (setf (vertices triangle)
	(sort (vertices triangle)
	      (lambda (v1 v2)
		(< (lm:z v1) (lm:z v2))))))

(defun strip-redundant-vertices (triangle-list)
  "Returns a mesh made from a list of explicite triangles"
  (let ((vertex-hash (make-hash-table
                      :test #'lm:vector=
                      :hash-function #'vector-hash))
        (mesh (make-instance 'mesh
                             :vertices '()
                             :triangles '()))
        (vertex-id 0))
    (loop
       for triangle in triangle-list
       for new-triangle = (make-instance
                           'triangle
                           :normal (explicit-triangle-normal triangle)) do
         (loop
            for vertex in (explicit-triangle-vertices triangle) do
              (multiple-value-bind (val present)
                  (gethash vertex vertex-hash)
                ;; Newly encountered vertex
                (unless present
                  (setf (gethash vertex vertex-hash) vertex-id)
                  (setf val vertex-id)
                  (incf vertex-id))
                ;; Push a triangle with id
                (push
                 val
                 (vertex-ids new-triangle))))
         (push
          new-triangle
          (triangles mesh)))
    (maphash (lambda (k v) (declare (ignore v)) (push k (vertices mesh))) vertex-hash)
    (setf (vertices mesh) (reverse (vertices mesh)))
    mesh))

;; Copyright (c) 2010, 2011, 2012 Raffael L. Mancini
;; <raffael.mancini@hcl-club.lu>

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

(defsystem :cl-mesh
  :version "0.2"
  :depends-on (:l-math :parse-number :cl-utilities :ieee-floats :lisp-unit)
  :components
  ((:file "system")
   (:file "cl-mesh" :depends-on ("system"))))

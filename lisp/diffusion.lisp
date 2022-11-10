#! /usr/bin/sbcl --script
; Ervin Pangilinan
; CSC 330: Organization of Programming Languages - Fall 2022
; Project 2: Simplified 3D Diffusion Model
; Implementation in Lisp

; Main Program
; PRE: User is prompted to enter number of subdivisions and if a partition is present. 
; POST: Outputs the ratio of concentration and time taken to equilibrate the room.

(progn
    (defvar maxSize)
    (defvar partitionPresent)
    (princ "Enter # of subdivisions: ")
    (terpri)
    (setf maxSize (read))
    (princ "Is partition present (yes/no): ")
    (terpri)
    (setf partitionPresent (read))

    ; Pre-defined values.
    (defvar diffusionCoefficient)
    (setf diffusionCoefficient 0.175)
    (defvar roomDimension)
    (setf roomDimension 5.0)
    (defvar speedofGasMolecules)
    (setf speedOfGasMolecules 250.0)
    (defvar timestep)
    (setf timestep (/ (/ roomDimension speedOfGasMolecules) maxSize))
    (defvar distanceBetweenBlocks)
    (setf distanceBetweenBlocks (/ roomDimension maxSize))
    (defvar DTerm)
    (setf DTerm (/ (* diffusionCoefficient timestep) (* distanceBetweenBlocks distanceBetweenBlocks)))

    ; To be checked in the simulation.
    (defvar simulatedTime)
    (defvar roomRatio)
    (defvar change)
    (defvar sumval)
    (defvar maxval)
    (defvar minval)
    (setf simulatedTime 0.0)
    (setf roomRatio 0.0)
    (setf change 0)

    ; 3D array representing the room.
    (defvar cube)
    (setf cube (make-array (list maxSize maxSize maxSize)))

    ; Used for indexing.
    (defvar i)
    (defvar j)
    (defvar k)
    (defvar l)
    (defvar m)
    (defvar n)
    (setf i 0)
    (setf j 0)
    (setf k 0)
    (setf l 0)
    (setf m 0)
    (setf n 0)

    ; Set everything in the room to 0. 
    (dotimes (i maxSize)
        (dotimes (j maxSize)
            (dotimes (k maxSize)
                (setf (aref cube i j k) 0)
            )
        )
    )
    (setf (aref cube 0 0 0) 1.0e21)

    ; Start simulation.
    (loop
        ; Reset indexing variables to 0.
        (setf i 0)
        (setf j 0)
        (setf k 0)
        (setf l 0)
        (setf m 0)
        (setf n 0)

        (dotimes (i maxSize)
            (dotimes (j maxSize)
                (dotimes (k maxSize)
                    (dotimes (l maxSize)
                        (dotimes (m maxSize)
                            (dotimes (n maxSize)
                                (if (or (and (= i l) (= j m) (= k (+ n 1)))     ; Move down. 
                                        (and (= i l) (= j m) (= k (- n 1)))     ; Move up.
                                        (and (= i l) (= j (+ m 1)) (= k n))     ; Move right.
                                        (and (= i l) (= j (- m 1)) (= k n))     ; Move left. 
                                        (and (= i (+ l 1)) (= j m) (= k n))     ; Move forward. 
                                        (and (= i (- l 1)) (= j m) (= k n)))    ; Move backwards. 
                                    (prog1
                                        (setf change (* (- (aref cube i j k) (aref cube l m n)) DTerm))
                                        (decf (aref cube i j k) change)
                                        (incf (aref cube l m n) change)
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )

        (setf simulatedTime (+ simulatedTime timestep))
        (setf maxval (aref cube 0 0 0))
        (setf minval (aref cube 0 0 0))
        (setf sumval 0)

        ; Reset to 0 for another nested loop. 
        (setf i 0)
        (setf j 0)
        (setf k 0)

        (dotimes (i maxSize)
            (dotimes (j maxSize)
                (dotimes (k maxSize)
                    (setf maxval (max (aref cube i j k) maxval))    ; Check for the maximum value in cube.
                    (setf minval (min (aref cube i j k) minval))    ; Check for the minimum value in cube.
                    (setf sumval (+ sumval (aref cube i j k)))
                )
            )
        )
        (setf roomRatio (/ minval maxval))

        (princ simulatedTime)
        (write-char #\Tab)
        (princ (aref cube 0 0 0))
        (write-char #\Tab)
        (princ (aref cube (- maxSize 1) 0 0))
        (write-char #\Tab)
        (princ (aref cube (- maxSize 1) (- maxSize 1) 0))
        (write-char #\Tab)
        (princ (aref cube (- maxSize 1) (- maxSize 1) (- maxSize 1)))
        (write-char #\Tab)
        (princ roomRatio)
        (terpri)
        (when (> roomRatio 0.99) (return cube))
    )

    (terpri)
    (princ "Box equilbirated in ")
    (princ simulatedTime)
    (princ " seconds of simulated time.")
    (terpri)
)

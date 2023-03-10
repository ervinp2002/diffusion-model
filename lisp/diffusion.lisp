#! /usr/bin/sbcl --script
; Ervin Pangilinan
; CSC 330: Organization of Programming Languages - Fall 2022
; Project 2: Simplified 3D Diffusion Model
; Implementation in Lisp

; Main Program
; PRE: User is prompted to enter number of subdivisions and if a partition is present. 
; POST: Outputs the ratio of concentration and time taken to equilibrate the room.

(prog
    (
        (maxSize (parse-integer (nth 1 sb-ext:*posix-argv*)))
        (partitionPresent (nth 2 sb-ext:*posix-argv*))
        (diffusionCoefficient 0.175)
        (roomDimension 5.0)
        (speedOfGasMolecules 250.0)
        (timestep 0.0)
        (distanceBetweenBlocks 0.0)
        (DTerm 0.0)
        (cube 0.0)
        (mask 0.0)
        (simulatedTime 0.0)
        (roomRatio 0.0d0)
        (change 0.0)
        (sumval 0.0)
        (maxval 0.0)
        (minval 0.0)
        (i 0)
        (j 0)
        (k 0)
        (l 0)
        (m 0)
        (n 0)
    )

    ; Set variables dependent on subdivisions
    (setf timestep (/ (/ roomDimension speedOfGasMolecules) maxSize))
    (setf distanceBetweenBlocks (/ roomDimension maxSize))
    (setf DTerm (/ (* diffusionCoefficient timestep) (* distanceBetweenBlocks distanceBetweenBlocks)))
    (setf cube (make-array (list maxSize maxSize maxSize)))

    ; Set everything in the room to 0. 
    (dotimes (i maxSize)
        (dotimes (j maxSize)
            (dotimes (k maxSize)
                (setf (aref cube i j k) 0)
            )
        )
    )
    (setf (aref cube 0 0 0) 1.0e21)         ; Initialize first index to contain all of the molecules. 
    (setf mask (make-array (list maxSize maxSize maxSize)))

    (if (string= partitionPresent "partition")
        (progn
            ; Set everything in the mask to 0. 
            (dotimes (i maxSize)
                (dotimes (j maxSize)
                    (dotimes (k maxSize)
                        (setf (aref mask i j k) 0)
                    )
                )
            )

            ; Set up 75% partition. 
            (setf j (+ (floor (/ maxSize 4)) 1))
            (setf k 0)
            (dotimes (j maxSize)
                (dotimes (k maxSize)
                    (setf (aref mask (floor (/ maxSize 2)) j k) 1)
                )
            ) 
        )
    )

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
                                    (progn
                                        (if (string= partitionPresent "partition")
                                            (prog1
                                                (if (and (= (aref mask i j k) 0) 
                                                         (= (aref mask l m n) 0))
                                                    (prog2
                                                        (setf change (* (- (aref cube i j k) (aref cube l m n)) DTerm))
                                                        (decf (aref cube i j k) change)
                                                        (incf (aref cube l m n) change)
                                                    )   
                                                ) 
                                            )
                                            (prog2
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
            )
        )

        (incf simulatedTime timestep)
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
                    (if (/= (aref cube i j k) 0)
                        (progn 
                            (setf maxval (max (aref cube i j k) maxval))    ; Check for the maximum value in cube.
                            (setf minval (min (aref cube i j k) minval))    ; Check for the minimum value in cube.
                            (incf sumval (aref cube i j k))
                        )  
                    )
                )
            )
        )
        (setf roomRatio (/ minval maxval))

        (setf i 3)
        (format t "~,vf" i simulatedTime)
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
    (setf i 3)
    (format t "~,vf" i simulatedTime)
    (princ " seconds of simulated time.")
    (terpri)
)

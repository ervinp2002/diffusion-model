/*
Ervin Pangilinan
CSC 330: Organization of Programming Languages - Fall 2022
Project 2: Simplified 3D Diffusion Model
Implementation in C++
*/

#include <iostream>
#include <iomanip>
#include <algorithm>
#include <cmath>
using namespace std;

// Basing implementation on Java sample code from class.
int main(int argc, char *argv[]) {
    // PRE: Flags are set to determine room dimension and if there's a partition in the room.
    // POST: Outputs the ratio of concentration and time taken to equilibrate the room. 

    // Number of subdivisions per dimension is determined by command-line argument. Defaults to 10 if there's no argument. 
    const int maxSize = atoi(argv[argc - 1]) > 0 ? atoi(argv[argc - 1]) : 10;

    double *room = new double[maxSize * maxSize * maxSize]; // Attempt at dynamic allocation for scalability.
    double diffusionCoefficient = 0.175;
    double roomDimension = 5;                      // In meters.
    double speedOfGasMolecules = 250.0;          // Based on 100 g/mol gas at RT.
    double timestep = (roomDimension / speedOfGasMolecules) / maxSize;          // h in seconds
    double distanceBetweenBlocks = roomDimension / maxSize;
    double DTerm = diffusionCoefficient * timestep / (distanceBetweenBlocks * distanceBetweenBlocks);
    double time = 0;
    double ratio = 0;

    // Set every point in the room to 0.
    for (int i = 0; i < maxSize; i++) {
        for (int j = 0; j < maxSize; j++) {
            for (int k = 0; k < maxSize; k++) {
                *(room + (i * maxSize * maxSize + j * maxSize + k)) = 0;
            }
        }
    }

    // Initialize first cell so it first contains the molecules.
    *room = 1.0e21;

    do {
        for (int i = 0; i < maxSize; i++) {
                for (int j = 0; j < maxSize; j++) {
                    for (int k = 0; k < maxSize; k++) {
                        for (int l = 0; l < maxSize; l++) {
                            for (int m = 0; m < maxSize; m++) {
                                for (int n = 0; n < maxSize; n++) {
                                    if (((i == l) && (j == m) && (k == n + 1)) ||  // move up
                                        ((i == l) && (j == m) && (k == n - 1)) ||  // move down
                                        ((i == l) && (j == m + 1) && (k == n)) ||  // move right
                                        ((i == l) && (j == m - 1) && (k == n)) ||  // move left
                                        ((i == l + 1) && (j == m) && (k == n)) ||  // move forward
                                        ((i == l - 1) && (j == m) && (k == n))) {  // move backwards

                                        double change = ((*(room + ((i * int(pow(maxSize, 2))) + (j * maxSize) + k))) 
                                                        - *(room + ((l * int(pow(maxSize, 2)) + (m * maxSize) + n)))) 
                                                        * DTerm;

                                        *(room + ((i * int(pow(maxSize, 2))) + (j * maxSize) + k)) = *(room + ((i * int(pow(maxSize, 2))) 
                                                                                                    + (j * maxSize) + k)) 
                                                                                                    - change;

                                        *(room + (l * int(pow(maxSize, 2)) + (m * maxSize) + n)) = *(room + (l * int(pow(maxSize, 2)) 
                                                                                                    + (m * maxSize) + n)) 
                                                                                                    + change;
                                }
                            }
                        }
                    }
                }
            }
        }

        time += timestep;
        double sumval = 0.0;
        double maxval = *room;
        double minval = *room;

        for (int i = 0; i < maxSize; i++) {
            for (int j = 0; j < maxSize; j++) {
                for (int k = 0; k < maxSize; k++) {
                    maxval = max(*(room + ((i * int(pow(maxSize, 2))) + (j * maxSize) + k)), maxval);
                    minval = min(*(room + ((i * int(pow(maxSize, 2))) + (j * maxSize) + k)), minval);
                    sumval += *(room + ((i * int(pow(maxSize, 2))) + (j * maxSize) + k));
                }
            }
        }

        ratio = minval / maxval;
        //cout << "Ratio:\t" << ratio << " \tTime:\t" << time << endl;
        cout << setprecision(6) << time << "\t";
        cout << setprecision(6) << *room << "\t";
        cout << *(room + (int(pow(maxSize, 3)) - int(pow(maxSize, 2)))) << " \t";

        /* Extreme pointer dereferencing where accessing 3D array indices are done by dereferencing then pulling 
        an address then dereferencing that address until the addresses for each dimensions have been dereferenced. */
        cout << setprecision(6) << *(&*(&*(room + (int(pow(maxSize, 3)) - int(pow(maxSize, 2)))) + (int(pow(maxSize, 2)) - maxSize))) << " \t";
        cout << setprecision(6) << *(&*(&*(room + (int(pow(maxSize, 3)) - int(pow(maxSize, 2)))) + (int(pow(maxSize, 2)) - maxSize)) + (maxSize - 1)) << " \t";
        cout << sumval << "\n";

    } while (ratio < 0.99);

    delete[] room;
    room = NULL;
    cout << "Box equilibrated in " << time << " seconds of simulated time." << endl;
    return 0;
}

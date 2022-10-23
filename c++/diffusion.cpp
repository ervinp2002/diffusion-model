/*
Ervin Pangilinan
CSC 330: Organization of Programming Languages - Fall 2022
Project 2: Simplified 3D Diffusion Model
Implementation in C++
*/

#include <iostream>
#include <algorithm>
#include <cmath>
#include <vector>
using namespace std;

// Basing implementation on Java sample code from class.
int main(int argc, char *argv[]) {
    // PRE: Flags are set to determine room dimension and if there's a partition in the room.
    // POST: Outputs the ratio of concentration and time taken to equilibrate the room. 

    // Number of subdivisions per dimension is determined by command-line argument. Defaults to 10 if there's no argument. 
    const int maxSize = atoi(argv[argc - 1]) > 0 ? atoi(argv[argc - 1]) : 10;

    // Attempt at dynamic allocation for scalability.
    vector<vector<vector<double>>> room(maxSize, vector<vector<double>>(10, vector<double> (10, 0))); 

    double diffusionCoefficient = 0.175;
    double roomDimension = 5;                      // In meters.
    double speedOfGasMolecules = 250.0;          // Based on 100 g/mol gas at RT.
    double timestep = (roomDimension / speedOfGasMolecules) / maxSize;          // h in seconds
    double distanceBetweenBlocks = roomDimension / maxSize;
    double DTerm = diffusionCoefficient * timestep / (distanceBetweenBlocks * distanceBetweenBlocks);
    double time = 0;
    double ratio = 0;

    // Initialize first cell so it first contains the molecules.
    room[0][0][0] = 1.0e21;

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

                                        double change = (room[i][j][k] - room[l][m][n]) * DTerm;
                                        room[i][j][k] = room[i][j][k] - change;
                                        room[l][m][n] = room[l][m][n] + change;
                                }
                            }
                        }
                    }
                }
            }
        }

        time += timestep;
        double sumval = 0.0;
        double maxval = room[0][0][0];
        double minval = room[0][0][0];

        for (int i = 0; i < maxSize; i++) {
            for (int j = 0; j < maxSize; j++) {
                for (int k = 0; k < maxSize; k++) {
                    maxval = max(room[i][j][k], maxval);
                    minval = min(room[i][j][k], minval);
                    sumval += room[i][j][k];
                }
            }
        }

        ratio = minval / maxval;
        cout << time << " \t " << room[0][0][0] <<  " \t ";
        cout << room[maxSize - 1][0][0] << " \t ";
        cout << room[maxSize - 1][maxSize - 1][0] << " \t ";
        cout << room[maxSize - 1][maxSize - 1][maxSize - 1] << " \t ";
        cout << sumval << endl;

    } while (ratio < 0.99);

    cout << "Box equilibrated in " << time << " seconds of simulated time." << endl;
    return 0;
}

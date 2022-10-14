#include <iostream>
#include <algorithm>
#include <cmath>
#include <vector>
using namespace std;

// Referring to Java sample code from class.
int main() {
    // PRE:
    // POST:

    const int maxSize = 10;
    double room[maxSize][maxSize][maxSize];
    double diffusionCoefficient = 0.175;
    double roomDimension = 5;                      // 5 Meters
    double speedOfGasMolecules = 250.0;          // Based on 100 g/mol gas at RT

    double timestep = (roomDimension / speedOfGasMolecules) / maxSize;          // h in seconds
    double distanceBetweenBlocks = roomDimension / maxSize;
    double DTerm = diffusionCoefficient * timestep / (distanceBetweenBlocks * distanceBetweenBlocks);

    double time = 0;
    double ratio = 0;

    // Set every point in the room to 0.
    for (int i = 0; i < maxSize; i++) {
        for (int j = 0; j < maxSize; j++) {
            for (int k = 0; k < maxSize; k++) {
                room[i][j][k] = 0;
            }
        }
    }

    // Initialize first cell so it first contains the molecules.
    room[0][0][0] = 1.0e21;

    do {
        for (int i = 0; i < maxSize; i++) {
                for (int j = 0; j < maxSize; j++) {
                    for (int k = 0; k < maxSize; k++) {
                        for (int l = 0; l < maxSize; l++) {
                            for (int m = 0; m < maxSize; m++) {
                                for (int n = 0; n < maxSize; n++) {

                                    if (    ( ( i == l )   && ( j == m )   && ( k == n + 1) ) ||
                                            ( ( i == l )   && ( j == m )   && ( k == n - 1) ) ||
                                            ( ( i == l )   && ( j == m + 1) && ( k == n)   ) ||
                                            ( ( i == l )   && ( j == m-1 ) && ( k == n)   ) ||
                                            ( ( i == l+1 ) && ( j == m )   && ( k == n)   ) ||
                                            ( ( i == l-1 ) && ( j == m )   && ( k == n)   ) ) {

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
        cout << "Ratio: " << ratio << "\tTime: " << time << endl;
    } while (ratio < 0.99);

    cout << "Box equilibrated in " << time << " seconds of simulated time." << endl;

    return 0;
}


/*
Ervin Pangilinan
CSC 330: Organization of Programming Languages - Fall 2022
Project 2: Simplified 3D Diffusion Model
Implementation in C++
*/

/*
To compile: c++ diffusion.cpp -O2
To execute: ./[binary file name] [number of subdivisions] ["partition" (leave blank if none)]
*/

using namespace std;
#include <iostream>
#include <algorithm>
#include <cmath>
#include <vector>
typedef vector<vector<vector<double>>> Cube;
typedef vector<vector<double>> Matrix;
typedef vector<vector<vector<int>>> BitMask;
typedef vector<vector<int>> CrossSection;

// Overloaded & dependent on if a flag has been set to put up a partition in the room.
void diffusion(Cube &room, BitMask &BitMask, const int &maxSize, const double &DTerm);     // Executes if there is a partition.
void diffusion(Cube &room, const int &maxSize, const double &DTerm);                       // Executes if there isn't.
void setBitMask(Cube &BitMask, const int &maxSize);

void diffusion(Cube &room, const int &maxSize, const double &DTerm) {
    // PRE: 3D array for the room and number of subdivisions have been initialized.
    // POST: Simulates the diffusion of molecules and writes into the 3D array of the room.

    double change;
    for (int i = 0; i < maxSize; i++) {
        for (int j = 0; j < maxSize; j++) {
            for (int k = 0; k < maxSize; k++) {
                for (int l = 0; l < maxSize; l++) {
                    for (int m = 0; m < maxSize; m++) {
                        for (int n = 0; n < maxSize; n++) {
                            if (((i == l) && (j == m) && (k == n + 1)) ||  // move down
                                ((i == l) && (j == m) && (k == n - 1)) ||  // move up
                                ((i == l) && (j == m + 1) && (k == n)) ||  // move right
                                ((i == l) && (j == m - 1) && (k == n)) ||  // move left
                                ((i == l + 1) && (j == m) && (k == n)) ||  // move forward
                                ((i == l - 1) && (j == m) && (k == n))) {  // move backwards

                                change = (room[i][j][k] - room[l][m][n]) * DTerm;
                                room[i][j][k] = room[i][j][k] - change;
                                room[l][m][n] = room[l][m][n] + change;
                            }
                        }
                    }
                }
            }
        }
    }  
}

void diffusion(Cube &room, BitMask &BitMask, const int &maxSize, const double &DTerm) {
    // PRE: 3D array for the room, BitMask, and number of subdivisions have been initialized.
    // POST: Uses the BitMask to simulate diffusion with partition in the room. 

    double change;
    for (int i = 0; i < maxSize; i++) {
        for (int j = 0; j < maxSize; j++) {
            for (int k = 0; k < maxSize; k++) {
                for (int l = 0; l < maxSize; l++) {
                    for (int m = 0; m < maxSize; m++) {
                        for (int n = 0; n < maxSize; n++) {
                            if ((((i == l) && (j == m) && (k == n + 1)) ||      // move down
                                ((i == l) && (j == m) && (k == n - 1)) ||       // move up
                                ((i == l) && (j == m + 1) && (k == n)) ||       // move right
                                ((i == l) && (j == m - 1) && (k == n)) ||       // move left
                                ((i == l + 1) && (j == m) && (k == n)) ||       // move forward
                                ((i == l - 1) && (j == m) && (k == n))) &&      // move backwards
                                (BitMask[i + 1][j + 1][k + 1] == 0 && BitMask[l + 1][m + 1][n + 1] == 0)) {  
                                change = (room[i][j][k] - room[l][m][n]) * DTerm;
                                room[i][j][k] = room[i][j][k] - change;
                                room[l][m][n] = room[l][m][n] + change;
                            }
                        }
                    }
                }
            }
        }
    }
}

void setBitMask(BitMask &BitMask, const int &maxSize) {
    // PRE: BitMask and number of subdivisions have been initialized. 
    // POST: Adjusts the the BitMask by putting in 1 in indices where the partition is present or is a wall.

    // Set up the 75% partition.
    for (int j = floor((maxSize / 4) + 1); j < maxSize + 2; j++) {
        for (int k = 0; k < maxSize + 2; k++) {
            BitMask[maxSize / 2][j][k] = 1;
        }
    }

    // Set up the front-facing wall.
    for (int j = 0; j < maxSize + 2; j++) {
        for (int k = 0; k < maxSize + 2; k++) {
            BitMask[0][j][k] = 1;
        }
    }

    // Set up the back-facing wall. 
    for (int j = 0; j < maxSize + 2; j++) {
        for (int k = 0; k < maxSize + 2; k++) {
            BitMask[maxSize + 1][j][k] = 1;
        }
    }

    // Set up the room's ceiling.
    for (int i = 0; i < maxSize + 2; i++) {
        for (int k = 0; k < maxSize + 2; k++) {
            BitMask[i][0][k] = 1;
        }
    }

    // Set up the room's floor. 
    for (int i = 0; i < maxSize + 2; i++) {
        for (int k = 0; k < maxSize + 2; k++) {
            BitMask[i][maxSize + 1][k] = 1;
        }
    }

    // Set up the left-facing wall.
    for (int i = 0; i < maxSize + 2; i++) {
        for (int j = 0; j < maxSize + 2; j++) {
            BitMask[i][j][0] = 1;
        }
    }

    // Set up the right-facing wall. 
    for (int i = 0; i < maxSize + 2; i++) {
        for (int j = 0; j < maxSize + 2; j++) {
            BitMask[i][j][maxSize + 1] = 1;
        }
    }
}

// Basing implementation on Java sample code from class.
int main(int argc, char *argv[]) {
    // PRE: Flags are set to determine room dimension and if there's a partition in the room.
    // POST: Outputs the ratio of concentration and time taken to equilibrate the room. 

    // Number of subdivisions per dimension is determined by command-line argument. Defaults to 10 if there's no argument. 
    const int maxSize = stoi(argv[1]) > 0 ? stoi(argv[1]) : 10;

    // Specify if there is a flag to set up partition in the room.
    string arg2 = argv[argc - 1];
    bool partitionPresent = arg2 == "partition" ? true : false;
    
    // Attempt at dynamic allocation for scalability.
    Cube room(maxSize, Matrix(maxSize, vector<double> (maxSize, 0))); 
    BitMask mask(maxSize + 2, CrossSection(maxSize + 2, vector<int> (maxSize + 2, 0)));
    if (partitionPresent) setBitMask(mask, maxSize);

    double diffusionCoefficient = 0.175;
    double roomDimension = 5;                                                   // In meters.
    double speedOfGasMolecules = 250.0;                                         // Based on 100 g/mol gas at RT.
    double timestep = (roomDimension / speedOfGasMolecules) / maxSize;          // h in seconds
    double distanceBetweenBlocks = roomDimension / maxSize;
    double DTerm = diffusionCoefficient * timestep / (distanceBetweenBlocks * distanceBetweenBlocks);
    double time = 0;
    double ratio = 0;

    // Initialize first cell so it first contains the molecules.
    room[0][0][0] = 1.0e21;

    do {
        if (partitionPresent) {
            diffusion(room, mask, maxSize, DTerm);
        } else {
            diffusion(room, maxSize, DTerm);
        }

        time += timestep;
        double sumval = 0.0;
        double maxval = room[0][0][0];
        double minval = room[0][0][0];

        for (int i = 0; i < maxSize; i++) {
            for (int j = 0; j < maxSize; j++) {
                for (int k = 0; k < maxSize; k++) {
                  if (room[i][j][k] != 0) {
                    maxval = max(room[i][j][k], maxval);
                    minval = min(room[i][j][k], minval);
                    sumval += room[i][j][k];          
                  }   
                }
            }
        }

        ratio = minval / maxval;
        std::cout << time << " \t " << room[0][0][0] <<  " \t ";
        std::cout << room[maxSize - 1][0][0] << " \t ";
        std::cout << room[maxSize - 1][maxSize - 1][0] << " \t ";
        std::cout << room[maxSize - 1][maxSize - 1][maxSize - 1] << " \t ";
        std::cout << ratio << endl;

    } while (ratio < 0.99);

    std::cout << "\nBox equilibrated in " << time << " seconds of simulated time." << endl;
    return 0;
}

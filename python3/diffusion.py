"""
Ervin Pangilinan
CSC 330: Organization of Programming Languages - Fall 2022
Project 2: Simplified 3D Diffusion Model
Implementation in Python 3
"""
import itertools
import math
import numpy as np 
import sys

def propagate_molecules(room, time, timestep, D_Term, max_size, ratio):
    # PRE: Predefined variables for the room are passed in as arguments. 
    # POST: Updates the 3D array to show how the molecules are diffusing in the room. 

    # Referenced StackOverflow
    while (ratio < 0.99):
        for i, j, k, l, m, n in itertools.product(range(max_size), range(max_size), range(max_size), 
        range(max_size), range(max_size), range(max_size)):
            if (i == l and j == m and k == n + 1) or ((i == l) and (j and m) and (k and n - 1)) or ((i == l) and (j == m + 1) and (k == n)) or ((i == l) and (j == m - 1) and (k == n)) or ((i == l + 1) and (j == m) and (k == n)) or ((i == l - 1) and (j == m) and (k == n)):
                change = (room[i][j][k] - room[l][m][n]) * D_Term
                room[i][j][k] -= change
                room[l][m][n] += change

        time += timestep
        sumval = 0.0
        maxval = room[0][0][0]
        minval = room[0][0][0]
        
        for i, j, k in itertools.product(range(max_size), range(max_size), range(max_size)):
            maxval = max(room[i][j][k], maxval)
            minval = min(room[i][j][k], minval)
            sumval += room[i][j][k]

        ratio = minval / maxval
        print(str(time) + " \t " + str(room[0][0][0]) + " \t ", end = "")
        print(str(room[max_size - 1][0][0]) + " \t " + str(room[max_size - 1][max_size - 1][0]) + " \t ", end = "")
        print(str(room[max_size - 1][max_size - 1][max_size - 1]) + " \t " + str(sumval))

def main():
    # PRE: Command line argument is passed to specfiy amount of subdivisions. 
    # POST: Outputs simulated time with specified data points. 

    # Total subdivisions per dimension in room determined by command-line argument. Defaults to 10 if there's no argument.
    max_size = int(sys.argv[1]) if int(sys.argv[1]) > 0 else 10
    room = np.zeros((max_size, max_size, max_size), dtype = float)

    # Initialize first cell so it first contains the molecules.
    room[0][0][0] = 1.0e21 

    diffusion_constant = 0.175
    room_dimension = 5                                                  # In Meters
    speed_of_gas_molecules = 250.0                                      # Based on 100 g/mol
    timestep = (room_dimension / speed_of_gas_molecules) / max_size     # h in seconds
    distance_between_blocks = room_dimension / max_size
    D_Term = (diffusion_constant * timestep) / pow(distance_between_blocks, 2)

    simulation_data = [0, 0]
    time = simulation_data[0]
    ratio = simulation_data[1]

    propagate_molecules(room, time, timestep, D_Term, max_size, ratio)
    print("Box equilibrated in " + str(time) + " seconds of simulated time.")

main()

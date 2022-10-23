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

def main():
    # PRE: Command line argument is passed to specfiy amount of subdivisions. 
    # POST: Outputs simulated time with specified data points. 

    # Number of subdivisions per dimension is determined by command-line argument. Defaults to 10 if there's no argument.
    max_size = 10 if int(sys.argv[1]) >= 10 else int(sys.argv[1])

    room = np.zeros((max_size, max_size, max_size), dtype = float)
    diffusion_constant = 0.175
    room_dimension = 5                                                  # In Meters
    speed_of_gas_molecules = 250.0                                      # Based on 100 g/mol
    timestep = (room_dimension / speed_of_gas_molecules) / max_size     # h in seconds
    distance_between_blocks = room_dimension / max_size
    D_Term = (diffusion_constant * timestep) / pow(distance_between_blocks, 2)
    time = 0
    ratio = 0

main()

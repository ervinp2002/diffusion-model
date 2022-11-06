#=
Ervin Pangilinan
CSC 330: Organization of Programming Languages - Fall 2022
Project 2: Simplified 3D Diffusion Model
Implementation in Julia
=#

# Flags to be determined by the user when passing in command-line arguments.
maxSize = isa(ARGS[1], Number) ? Int64(ARGS[1]) : 10
partitionPresent = length(ARGS) - 1 >= 1 && ARGS[2] == "partition" ? true : false

# Pre-defined variables
diffusionConstant = 0.175
roomDimension = 5                                                   # In Meters
speedOfGasMolecules = 250.0                                         # Based on 100 g/mol
timestep = (roomDimension / speedOfGasMolecules) / maxSize          # h in seconds
distanceBetweenBlocks = roomDimension / maxSize
DTerm = (diffusionConstant * timestep) / (distanceBetweenBlocks ^ 2)
time = 0
change = 0
ratio = 0

# 3D Array to represent the room. 
room = zeros(Float64, maxSize, maxSize, maxSize)
room[1, 1, 1] = 1.0e21                                              # Initialize first cell so it first contains the molecules.

while ratio < 0.99
    for i in 1 : maxSize
        for j in 1 : maxSize
            for k in 1 : maxSize
                for l in 1 : maxSize
                    for m in 1 : maxSize
                        for n in 1 : maxSize
                            if i == l && j == m && k == n + 1
                                global change = (room[i, j, k] - room[l, m, n]) * DTerm
                                room[i, j, k] -= change
                                room[l, m, n] += change
                            elseif i == l && j == m && k == n - 1
                                global change = (room[i, j, k] - room[l, m, n]) * DTerm
                                room[i, j, k] -= change
                                room[l, m, n] += change
                            elseif i == l && j == m + 1 && k == n 
                                global change = (room[i, j, k] - room[l, m, n]) * DTerm
                                room[i, j, k] -= change
                                room[l, m, n] += change
                            elseif i == l && j == m - 1 && k == n
                                global change = (room[i, j, k] - room[l, m, n]) * DTerm
                                room[i, j, k] -= change
                                room[l, m, n] += change
                            elseif i == l + 1 && j == m && k == n 
                                global change = (room[i, j, k] - room[l, m, n]) * DTerm
                                room[i, j, k] -= change
                                room[l, m, n] += change
                            elseif i == l - 1 && j == m && k == n
                                global change = (room[i, j, k] - room[l, m, n]) * DTerm
                                room[i, j, k] -= change
                                room[l, m, n] += change
                            end
                        end
                    end
                end
            end
        end
    end

    global time += timestep
    sumval = 0
    maxval = room[1, 1, 1]
    minval = room[1, 1, 1]

    for i in 1 : maxSize
        for j in 1 : maxSize
            for k in 1 : maxSize
                maxval = max(room[i, k, j], maxval)
                minval = min(room[i, k, j], minval)
                sumval += room[i, k, j]
            end
        end
    end

    global ratio = minval / maxval
    print(string(round(time; digits = 3)))
    print(" \t ", string(round(room[1, 1, 1]; digits = 5)))
    print(" \t ", string(round(room[maxSize, 1, 1]; digits = 5)))
    print(" \t ", string(round(room[maxSize, maxSize, 1]; digits = 5)))
    print(" \t ", string(round(room[maxSize, maxSize, maxSize]; digits = 5)))
    println(" \t ", string(ratio))
end
     
println("Box equilibrated in " + string(round(time; digits = 3)) + " seconds of simulated time.")

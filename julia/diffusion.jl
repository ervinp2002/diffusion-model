#=
Ervin Pangilinan
CSC 330: Organization of Programming Languages - Fall 2022
Project 2: Simplified 3D Diffusion Model
Implementation in Julia
=#

using Printf
# Flags to be determined by the user when passing in command-line arguments.
maxSize = isa(ARGS[1], Number) ? Int64(ARGS[1]) : 10
partitionPresent = length(ARGS) - 1 >= 1 && ARGS[2] == "partition" ? true : false

# Pre-defined variables
diffusionCoefficient = 0.175
roomDimension = 5                                                   # In Meters
speedOfGasMolecules = 250.0                                         # Based on 100 g/mol
timestep = (roomDimension / speedOfGasMolecules) / maxSize          # h in seconds
distanceBetweenBlocks = roomDimension / maxSize
DTerm = (diffusionCoefficient * timestep) / (distanceBetweenBlocks ^ 2)
time = 0
ratio = 0

# 3D Array to represent the room. 
room = zeros(Float64, maxSize, maxSize, maxSize)
room[1, 1, 1] = 1.0e21                                              # Initialize first cell so it first contains the molecules.
if partitionPresent
    mask = zeros(Int32, maxSize + 2, maxSize + 2, maxSize + 2)

    # Set up 75% partition in mask. 
    for j in Int32(floor((maxSize + 2) / 4) + 2): maxSize + 2
        for k in 1 : maxSize + 2
            mask[Int32(maxSize / 2), j, k] = 1
        end 
    end

    # Set up front-facing wall. 
    for j in 1 : maxSize + 2
        for k in 1 : maxSize + 2
            mask[1, j, k] = 1
        end
    end
    
    # Set up back-facing wall. 
    for j in 1 : maxSize + 2
        for k in 1 : maxSize + 2
            mask[maxSize + 2, j, k] = 1
        end 
    end
    
    # Set up top-facing wall. 
    for i in 1 : maxSize + 2
        for k in 1 : maxSize + 2
            mask[i, 1, k] = 1
        end 
    end 

    # Set up bottom-facing wall. 
    for i in 1 : maxSize + 2
        for k in 1 : maxSize + 2
            mask[i, maxSize + 2, k] = 1
        end 
    end 

    # Set up left-facing wall. 
    for i in 1 : maxSize + 2
        for j in 1 : maxSize + 2
            mask[i, j, 1] = 1
        end 
    end 

    # Set up right-facing wall.
    for i in 1 : maxSize + 2
        for j in 1 : maxSize + 2
            mask[i, j, maxSize + 2] = 1
        end 
    end

end 

while ratio < 0.99
    for i in 1 : maxSize
        for j in 1 : maxSize
            for k in 1 : maxSize
                for l in 1 : maxSize
                    for m in 1 : maxSize
                        for n in 1 : maxSize
                            if ((i == l && j == m && k == n + 1) ||
                                (i == l && j == m && k == n - 1) ||
                                (i == l && j == m + 1 && k == n) ||
                                (i == l && j == m - 1 && k == n) ||
                                (i == l + 1 && j == m && k == n) ||
                                (i == l - 1 && j == m && k == n))
                                if partitionPresent
                                    if mask[i + 1, j + 1, k + 1] == 0 && mask[l + 1, m + 1, n + 1] == 0
                                        change = (room[i, j, k] - room[l, m, n]) * DTerm
                                        room[i, j, k] -= change
                                        room[l, m, n] += change
                                    end
                                else
                                    change = (room[i, j, k] - room[l, m, n]) * DTerm
                                    room[i, j, k] -= change
                                    room[l, m, n] += change  
                                end
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
                if room[i, j, k] != 0
                    maxval = max(maxval, room[i, j, k])
                    minval = min(minval, room[i, j, k])
                    sumval += room[i, j, k]
                end
            end
        end
    end

    global ratio = minval / maxval
    print(string(round(time; digits = 3)))
    print(" \t ")
    @printf("% e", room[1, 1, 1])
    print(" \t ")
    @printf("% e", room[maxSize, 1, 1])
    print(" \t ")
    @printf("% e", room[maxSize, maxSize, 1])
    print(" \t ")
    @printf("% e", room[maxSize, maxSize, maxSize])
    println(" \t ", string(ratio))
end
     
println("Box equilibrated in ", string(round(time; digits = 3)), " seconds of simulated time.")

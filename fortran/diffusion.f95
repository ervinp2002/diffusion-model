! Ervin Pangilinan
! CSC 330: Organization of Programming Languages - Fall 2022
! Project 2: Simplified 3D Diffusion Model
! Implementation in Fortran 95

program main
    implicit none
    ! PRE: Command line argument is passed to specfiy amount of subdivisions. 
    ! POST: Outputs simulated time with specified data points. 

    real(kind = 8), dimension(:, :, :), allocatable :: room
    integer(kind = 8) :: max_size
    character(len = 20) :: arg
    real(kind = 8) :: diffusion_constant
    real(kind = 8) :: room_dimension                ! In meters.                              
    real(kind = 8) :: speed_of_gas_molecules        ! Based on 100 g/mol.
    real(kind = 8) :: timestep                      ! h in seconds.
    real(kind = 8) :: distance_between_blocks
    real(kind = 8) :: D_Term
    real(kind = 8) :: time
    real(kind = 8) :: ratio
    call get_command_argument(1, arg)
    read(arg, *) max_size
    allocate(room(max_size, max_size, max_size))
    
    diffusion_constant = 0.175
    room_dimension = 5.0
    speed_of_gas_molecules = 250.0
    timestep = (room_dimension / speed_of_gas_molecules) / max_size
    distance_between_blocks = room_dimension / max_size
    D_Term = (diffusion_constant * timestep) / (distance_between_blocks ** 2)
    time = 0.0
    ratio = 0.0



end program main

! Ervin Pangilinan
! CSC 330: Organization of Programming Languages - Fall 2022
! Project 2: Simplified 3D Diffusion Model
! Implementation in Fortran 95

program main
    implicit none
    ! PRE: Command line argument is passed to specfiy amount of subdivisions. 
    ! POST: Outputs simulated time with specified data points. 

    ! 3D array representing the room.
    real(kind = 8), dimension(:, :, :), allocatable :: room
    integer, dimension(:, :, :), allocatable :: mask
    integer :: i, j, k, l, m, n

    ! Command line arguments
    integer :: max_size
    character(len = 20) :: arg

    real(kind = 8) :: diffusion_coefficient
    real(kind = 8) :: room_dimension                ! In meters.                              
    real(kind = 8) :: speed_of_gas_molecules        ! Based on 100 g/mol.
    real(kind = 8) :: timestep                      ! h in seconds.
    real(kind = 8) :: distance_between_blocks
    real(kind = 8) :: D_Term
    real(kind = 8) :: time
    real(kind = 8) :: ratio
    real(kind = 8) :: change
    real(kind = 8) :: minval 
    real(kind = 8) :: maxval
    logical :: partitionPresent

    call get_command_argument(1, arg)
    read(arg, *) max_size
    allocate(room(max_size, max_size, max_size))

    call get_command_argument(command_argument_count(), arg)
    partitionPresent = merge(.true., .false., arg == "partition")                   ! Ternary operator in Fortran

    if (partitionPresent .eqv. .true.) then
        allocate(mask(0 : max_size + 1, 0 : max_size + 1, 0 : max_size + 1))
        mask = 0

        ! Set up the partition
        do j = floor(real((max_size / 4) + 1)), max_size + 1
            do k = 0, max_size + 1
                mask(max_size / 2, j, k) = 1
            end do
        end do

        ! Front-facing side
        do j = 0, max_size + 1
            do k = 0, max_size + 1
                mask(0, j, k) = 1
            end do 
        end do

        ! Back-facing side
        do j = 0, max_size + 1
            do k = 0, max_size + 1
                mask(max_size + 1, j, k) = 1
            end do 
        end do

        ! Top-facing side
        do i = 0, max_size + 1
            do k = 0, max_size + 1
                mask(i, 0, k) = 1
            end do 
        end do

        ! Bottom-facing side
        do i = 0, max_size + 1
            do k = 0, max_size + 1
                mask(i, max_size + 1, k) = 1
            end do 
        end do 

        ! Left-facing side
        do i = 0, max_size + 1
            do j = 0, max_size + 1
                mask(i, j, 0) = 1
            end do 
        end do 

        ! Right-facing side 
        do i = 0, max_size + 1
            do j = 0, max_size + 1
                mask(i, j, max_size + 1) = 1
            end do 
        end do 

    end if

    diffusion_coefficient = 0.175
    room_dimension = 5.0
    speed_of_gas_molecules = 250.0
    timestep = (room_dimension / speed_of_gas_molecules) / max_size
    distance_between_blocks = room_dimension / max_size
    D_Term = (diffusion_coefficient * timestep) / (distance_between_blocks ** 2)
    time = 0.0
    ratio = 0.0

    room = 0                    ! Zero every point in the room.
    room(1, 1, 1) = 1.0e21      ! Initialize first cell so it first contains the molecules.

    do while (ratio < 0.99)
        do i = 1, max_size
            do j = 1, max_size
                do k = 1, max_size
                    do l = 1, max_size
                        do m = 1, max_size
                            do n = 1, max_size
                                ! This checks every adjacent spot for the molecules to propagate to. 
                                if ((((i == l) .and. (j == m) .and. (k == n + 1))) .or. &
                                    ((i == l) .and. (j == m) .and. (k == n - 1)) .or. &
                                    ((i == l) .and. (j == m + 1) .and. (k == n)) .or. &
                                    ((i == l) .and. (j == m - 1) .and. (k == n)) .or. &
                                    ((i == l + 1) .and. (j == m) .and. (k == n)) .or. &
                                    ((i == l - 1) .and. (j == m) .and. (k == n))) then
                                        if (partitionPresent .eqv. .true.) then
                                            if (mask(k, j, i) == 0 .and. mask(n, m, l) == 0) then
                                                call change_values(change, room(k, j, i), room(n, m, l), D_Term)
                                            end if
                                        else
                                            call change_values(change, room(k, j, i), room(n, m, l), D_Term)
                                        end if
                                end if
                            end do
                        end do
                    end do
                end do
            end do
        end do

        time = time + timestep
        minval = room(1, 1, 1)
        maxval = room(1, 1, 1)
        do i = 1, max_size
            do j = 1, max_size
                do k = 1, max_size
                    if (room(k, j, i) /= 0) then
                        minval = min(minval, room(k, j, i))
                        maxval = max(maxval, room(k, j, i))
                    end if
                end do
            end do 
        end do
        ratio = minval / maxval

        write(*, "(f10.3)", advance = 'no') time
        write(*, "(4x, 4es15.5)", advance = 'no') room(1, 1, 1), room(max_size, 1, 1)
        write(*, "(4x, 4es15.5)", advance = 'no') room(max_size, max_size, 1), room(max_size, max_size, max_size)
        write(*, "(4x, 4es15.5)") ratio

    end do

    deallocate(room)
    if (partitionPresent) then
        deallocate(mask)
    end if 

    write(*, "(A)", advance = 'no') "Simulated time for box equilibration: "
    write(*, "(f10.3)") time
    
    contains
        subroutine change_values(change, room_value, traveled_point, D_Term)
            implicit none
            ! PRE: Array indices referring to the room are initialized. 
            ! POST: Adjust the the amount of molecules in a room index. 
            
            real(kind = 8), intent(inout) :: change
            real(kind = 8), intent(inout) :: room_value
            real(kind = 8), intent(inout) :: traveled_point
            real(kind = 8), intent(in) :: D_Term

            change = (room_value - traveled_point) * D_Term
            room_value = room_value - change
            traveled_point = traveled_point + change

        end subroutine change_values

end program main

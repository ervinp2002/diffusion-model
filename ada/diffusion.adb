-- Ervin Pangilinan
-- CSC 330: Organization of Programming Languages - Fall 2022
-- Project 2: Simplified 3D Diffusion Model
-- Implementation in Ada

with Ada.Text_IO, Ada.Float_Text_IO, Ada.Command_Line, Ada.Characters.Latin_1;
use Ada.Text_IO, Ada.Float_Text_IO, Ada.Command_Line, Ada.Characters.Latin_1;

procedure Diffusion is
-- MAIN PROGRAM
-- PRE: Command line argument is passed to specfiy amount of subdivisions. 
-- POST: Outputs simulated time with specified data points.
    type Cube is array (Integer range <>, Integer range <>, Integer range <>) of Long_Float;
    type BitMask is array (Integer range<>, Integer range <>, Integer range<>) of Integer;
    maxSize: Integer := Integer'Value(Argument(1));
    partitionPresent: Boolean := (if Argument_Count >= 2 and Argument(Argument_Count - 0) = "partition" then True else False);
    
begin
    if maxSize < 0 then
        maxSize := 10;
    end if;

    declare 
        -- Predefined Variables
        diffusionCoefficient: Long_Float := 0.175;
        roomDimension: Long_Float := 5.0;
        speedOfGasMolecules: Long_Float := 250.0;
        timestep: Long_Float := (roomDimension / speedOfGasMolecules) / Long_Float(maxSize);
        distanceBetweenBlocks: Long_Float := roomDimension / Long_Float(maxSize);
        DTerm: Long_Float := (diffusionCoefficient * timestep) / (distanceBetweenBlocks * distanceBetweenBlocks);

        -- Variables to be modified during simulation
        room: Cube(1..maxSize, 1..maxSize, 1..maxSize);
        mask: BitMask(1..maxSize + 2, 1..maxSize + 2, 1..maxSize + 2);
        change: Long_Float;
        sumval: Long_Float;
        minval: Long_Float;
        maxval: Long_Float;
        ratio: Long_Float;
        time: Long_Float;

    begin
        if partitionPresent then
            mask := (others => (others => (others => 0)));

            -- Set up the 75% partition. 
            for j in Integer(Float'Ceiling(Float(maxSize / 4) - 1.0))..maxSize + 2 loop 
                for k in 1..maxSize + 2 loop 
                    mask(Integer(Float'Ceiling(Float(maxSize / 2))), j, k) := 1;
                end loop;
            end loop;

            -- Set up the front-facing wall. 
            for j in 1..maxSize + 2 loop 
                for k in 1..maxSize + 2 loop 
                    mask(1, j, k) := 1;
                end loop;
            end loop;

            -- Set up the back-facing wall. 
            for j in 1..maxSize + 2 loop 
                for k in 1..maxSize + 2 loop 
                    mask(maxSize + 2, j, k) := 1;
                end loop;
            end loop;

            -- Set up the ceiling. 
            for i in 1..maxSize + 2 loop 
                for k in 1..maxSize + 2 loop 
                    mask(i, 1, k) := 1;
                end loop;
            end loop;

            -- Set up the floor. 
            for i in 1..maxSize + 2 loop 
                for k in 1..maxSize + 2 loop 
                    mask(i, maxSize + 2, k) := 1;
                end loop;
            end loop;

            -- Set up the left-facing wall. 
            for i in 1..maxSize + 2 loop 
                for j in 1..maxSize + 2 loop 
                    mask(i, j, 1) := 1;
                end loop;
            end loop;

            -- Set up the right-facing wall. 
            for i in 1..maxSize + 2 loop 
                for j in 1..maxSize + 2 loop 
                    mask(i, j, maxSize + 2) := 1;
                end loop;
            end loop;
        end if;

        room := (others => (others => (others => 0.0)));
        time := 0.0;
        change := 0.0;
        sumval := 0.0;
        ratio := 0.0;
        room(1, 1, 1) := 1.0e21;

        while ratio < 0.99 loop
            for i in 1..maxSize loop
                for j in 1..maxSize loop
                    for k in 1..maxSize loop
                        for l in 1..maxSize loop
                            for m in 1..maxSize loop
                                for n in 1..maxSize loop
                                    if (i = l and j = m and k = n + 1)          -- Move down
                                    or (i = l and j = m and k = n - 1)          -- Move up
                                    or (i = l and j = m + 1 and k = n)          -- Move right
                                    or (i = l and j = m - 1 and k = n)          -- Move left
                                    or (i = l + 1 and j = m and k = n)          -- Move forward
                                    or (i = l - 1 and j = m and k = n) then     -- Move backward
                                        if partitionPresent then
                                            if mask(i + 1, j + 1, k + 1) = 0 and mask(l + 1, m + 1, n + 1) = 0 then
                                                change := Long_Float((room(i, j, k) - room(l, m, n)) * DTerm);
                                                room(i, j, k) := room(i, j, k) - change;
                                                room(l, m, n) := room(l, m, n) + change;
                                            end if;
                                        else 
                                            change := Long_Float((room(i, j, k) - room(l, m, n)) * DTerm);
                                            room(i, j, k) := room(i, j, k) - change;
                                            room(l, m, n) := room(l, m, n) + change;
                                        end if;
                                    end if;
                                end loop;
                            end loop;
                        end loop;
                    end loop;
                end loop;
            end loop;

            time := time + timestep;
            sumval := 0.0;
            minval := room(1, 1, 1);
            maxval := room(1, 1, 1);
            for i in 1..maxSize loop
                for j in 1..maxSize loop
                    for k in 1..maxSize loop
                        if room(i, j, k) /= 0.0 then
                            minval := Long_Float'Min(room(i, j, k), minval);
                            maxval := Long_Float'Max(room(i, j, k), maxval);
                            sumval := sumval + room(i, j, k);
                        end if;
                    end loop;
                end loop;
            end loop;
            ratio := minval / maxval;

            Put(long_float'image(time));
            Put(HT);
            Put(long_float'image(room(1, 1, 1)));
            Put(HT);
            Put(long_float'image(room(maxSize, 1, 1)));
            Put(HT);
            Put(long_float'image(room(maxSize, maxSize, 1)));
            Put(HT);
            Put(long_float'image(room(maxSize, maxSize, maxSize)));
            Put(HT);
            Put(long_float'image(ratio));
            Put_Line("");
        end loop;

        New_Line;
        Put("Box equilibrated in ");
        Put(long_float'image(time));
        Put_Line(" seconds of simulated time.");
    end;
end Diffusion;

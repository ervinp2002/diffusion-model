-- Ervin Pangilinan
-- CSC 330: Organization of Programming Languages - Fall 2022
-- Project 2: Simplified 3D Diffusion Model
-- Implementation in Ada

with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Float_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Float_Text_IO;

procedure Diffusion is
-- MAIN PROGRAM --
-- PRE: Command line argument is passed to specfiy amount of subdivisions. 
-- POST: Outputs simulated time with specified data points.
    type Cube is array (Integer range <>, Integer range <>, Integer range <>) of Long_Float;
    maxSize: Integer := 10;

begin
    declare 
        diffusionCoefficient: Long_Float := 0.175;
        roomDimension: Long_Float := 5.0;
        speedOfGasMolecules: Long_Float := 250.0;
        timestep: Long_Float := (roomDimension / speedOfGasMolecules) / maxSize;
        distanceBetweenBlocks: Long_Float := roomDimension / maxSize;
        DTerm: Long_Float := (diffusionCoefficient * timestep) / (distanceBetweenBlocks * distanceBetweenBlocks);
        time: Long_Float := 0.0;
        ratio: Long_Float := 0.0;

    begin



    end;
end Diffusion;

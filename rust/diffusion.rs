/*
Ervin Pangilinan
CSC 330: Organization of Programming Languages - Fall 2022
Project 2: Simplified 3D Diffusion Model
Implementation in Rust
*/

use std::env;

fn main() {
    // PRE: Command line arguments are passed to determine subdivisions and partition in room. 
    // POST: Outputs the ratio of concentration and time taken to equilibrate the room. 

    // Contains command-line flags to be parsed. 
    let args: Vec<String> = env::args().collect();      
    let max_size: i64 = args[1].parse().unwrap();
    let partition_present: bool = if args.len() - 1 >= 1 && args[args.len() - 1] == "partition" {true} else {false};

    // Pre-defined values. 
    const DIFFUSION_CONSTANT: f64 = 0.175;             
    const ROOM_DIMENSION: f64 = 5.0;                                                      // In meters. 
    const SPEED_OF_GAS_MOLECULES: f64 = 250.0;                                            // Based on 100 g/mol
    let timestep: f64 = (ROOM_DIMENSION / SPEED_OF_GAS_MOLECULES) / (max_size as f64);    // h in seconds
    let distance_between_blocks: f64 = ROOM_DIMENSION / (max_size as f64);
    let d_term: f64 = (DIFFUSION_CONSTANT * timestep) / (distance_between_blocks * distance_between_blocks);

    
    /*
    println!("{}", max_size);
    println!("{}", partition_present);
    println!("{}", DIFFUSION_CONSTANT);
    println!("{}", ROOM_DIMENSION);
    println!("{}", SPEED_OF_GAS_MOLECULES);
    println!("{}", timestep);
    println!("{}", distance_between_blocks);
    println!("{}", d_term);
    */



}

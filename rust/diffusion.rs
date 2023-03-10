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
    const DIFFUSION_COEFFICIENT: f64 = 0.175;             
    const ROOM_DIMENSION: f64 = 5.0;                                                      // In meters. 
    const SPEED_OF_GAS_MOLECULES: f64 = 250.0;                                            // Based on 100 g/mol
    let timestep: f64 = (ROOM_DIMENSION / SPEED_OF_GAS_MOLECULES) / (max_size as f64);    // h in seconds
    let distance_between_blocks: f64 = ROOM_DIMENSION / (max_size as f64);
    let d_term: f64 = (DIFFUSION_COEFFICIENT * timestep) / (distance_between_blocks * distance_between_blocks);

    // Mutable variables to be used. 
    let mut time: f64 = 0.0;
    let mut ratio: f64 = 0.0;
    let mut room = vec![vec![vec![0.0; max_size as usize]; max_size as usize]; max_size as usize];
    let mut mask = vec![vec![vec![0; (max_size + 2) as usize]; (max_size + 2) as usize]; (max_size + 2) as usize];
    room[0][0][0] = 1e+21_f64;

    if partition_present {
        // Set up the 75% partition. 
        for j in (((max_size / 4) + 1) as f64).floor() as usize..(max_size + 2) as usize {
            for k in 0..(max_size + 2) as usize {
                mask[((max_size / 2) as f64).floor() as usize][j][k] = 1;
            }
        }

        // Set up the front-facing wall. 
        for j in 0..(max_size + 2) as usize {
            for k in 0..(max_size + 2) as usize {
                mask[0][j][k] = 1;
            }
        }

        // Set up the back-facing wall.
        for j in 0..(max_size + 2) as usize {
            for k in 0..(max_size + 2) as usize {
                mask[(max_size + 1) as usize][j][k] = 1;
            }
        }

        // Set up the room's ceiling.
        for i in 0..(max_size + 2) as usize {
            for k in 0..(max_size + 2) as usize {
                mask[i][0][k] = 1;
            }
        }

        // Set up the room's floor. 
        for i in 0..(max_size + 2) as usize {
            for k in 0..(max_size + 2) as usize {
                mask[i][(max_size + 1) as usize][k] = 1;
            }
        }

        // Set up the left-facing wall.
        for i in 0..(max_size + 2) as usize {
            for j in 0..(max_size + 2) as usize {
                mask[i][j][0] = 1;
            }
        }

        // Set up the right-facing wall. 
        for i in 0..(max_size + 2) as usize {
            for j in 0..(max_size + 2) as usize {
                mask[i][j][(max_size + 1) as usize] = 1;
            }
        }

    }

    while ratio < 0.99 {
        for i in 0..max_size {
            for j in 0..max_size {
                for k in 0..max_size {
                    for l in 0..max_size {
                        for m in 0..max_size {
                            for n in 0..max_size {
                                if  (i == l && j == m && k == n + 1) ||                     // move down
                                    (i == l && j == m && k == n - 1) ||                     // move up
                                    (i == l && j == m + 1 && k == n) ||                     // move right
                                    (i == l && j == m - 1 && k == n) ||                     // move left
                                    (i == l + 1 && j == m && k == n) ||                     // move forward
                                    (i == l - 1 && j == m && k == n) {                      // move backwards
                                    if partition_present {
                                        if mask[(i + 1) as usize][(j + 1) as usize][(k + 1) as usize] == 0 &&
                                        mask[(l + 1) as usize][(j + 1) as usize][(k + 1) as usize] == 0 {

                                            let change = (room[i as usize][j as usize][k as usize] 
                                                - room[l as usize][m as usize][n as usize]) * d_term;
                                            room[i as usize][j as usize][k as usize] -= change;
                                            room[l as usize][m as usize][n as usize] += change;
                                        }
                                    } else {
                                        let change = (room[i as usize][j as usize][k as usize] 
                                            - room[l as usize][m as usize][n as usize]) * d_term;
                                        room[i as usize][j as usize][k as usize] -= change;
                                        room[l as usize][m as usize][n as usize] += change;
                                    }   
                                }
                            }
                        }
                    }
                }
            }
        }

        time += timestep;
        let mut _sumval: f64 = 0.0;
        let mut minval: f64 = room[0][0][0];
        let mut maxval: f64 = room[0][0][0];
    
        for i in 0..max_size as usize {
            for j in 0..max_size as usize {
                for k in 0..max_size as usize {
                    if room[i][j][k] != 0.0 {
                        maxval = maxval.max(room[i][j][k]);
                        minval = minval.min(room[i][j][k]);
                        _sumval += room[i][j][k];
                    }  
                }
            }
        } 
    
        ratio = minval / maxval;
        println!("{:.3} \x09 {:.5e} \x09 {:.5e} \x09 {:.5e} \x09 {:.5e} \x09 {:.5e}", 
            time, 
            room[0][0][0], 
            room[max_size as usize - 1][0][0], 
            room[max_size as usize - 1][max_size as usize - 1][0], 
            room[max_size as usize - 1][max_size as usize - 1][max_size as usize - 1], ratio);
    }

    println!("\x0ABox equilibrated in {:.3} seconds of simulated time.", time);
}

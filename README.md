# Simplified 3D Diffusion Model

## Compilation and Execution

C++

    c++ diffusion.cpp -O2
    ./a.out [# of subdivisions] [partition (blank if simulating without it)]

Python 3

    python3 diffusion.py [# of subdivisions] [partition (blank if simulating without it)]

Fortran 95

    gfortran diffusion.f95 -O2
    ./a.out [# of subdivisions] [partition (blank if simulating without it)]

Rust

    rustc diffusion.rs -O
    diffusion [# of subdivisions] [partition (blank if simulating without it)]

Julia

    chmod u+x diffusion.jl
    ./diffusion.jl [# of subdivisions] [partition (blank if simulating without it)]

Ada

    gnatmake diffusion.adb -O2 -gnat2012
    diffusion [# of subdivisions] [partition (blank if simulating without it)]

Common Lisp

    chmod u+x diffusion.lisp
    ./diffusion.lisp [# of subdivisions] [partition (blank if simulating without it)]

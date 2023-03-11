## Sudoku2
A Sudoku solver using D.Knuth's Algorithm X implemented by his Dancing Links pseudo-code.

This package was developed in order to verify that the package "DancingLinks" is properly working.

Note that Sudoku2 is NOT a puzzle generator.

Before usage, function `set_box_size` must be called once to initialize Sudoku2, and to set the default DancingLinks global var 
`incidence_matrix` - the 'exact cover' matrix.

## Exported:
+ set_box_size
    Set the component box width (eg, 3 for a 9x9 puzzle).
+ board
    A Matrix{Cell) initialized by `set_box_size`.
+ solve
    Solve the `board` (with or without 'givens'.
+ is_valid_sudoku
    Is the global var `board` a valid Sudoku solution?
+ set_random_solution
    Create a random solution (print the result with string(board)).
+ convert_nanoseconds`
    Helper

## Example:
    # prints out a randomized 4x4 Sudoku solution:
    set_box_size(2)
    set_random_solution(verbose=true)
    println(string(board))

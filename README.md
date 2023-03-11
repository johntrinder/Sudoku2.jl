## Sudoku2
A Sudoku solver using D.Knuth's Algorithm X implemented by his Dancing Links pseudo-code.

This package was developed in order to verify that the package "DancingLinks" is properly working.

Note that Sudoku2 is NOT a puzzle generator.

Before usage, function `set_box_size` must be called once to initialize Sudoku2, and to set the default DancingLinks global var 
`incidence_matrix` - the 'exact cover' matrix.

# Exported:
+ `set_box_size, board, solve, is_valid_sudoku, set_random_solution, convert_nanoseconds`

# Example:
    # prints out a randomized 4x4 Sudoku solution
    set_box_size(2)
    set_random_solution(verbose=true)
    println(string(board))

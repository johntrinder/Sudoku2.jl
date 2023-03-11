"""
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
+
"""
module Sudoku2

using DancingLinks

include("Cell.jl")

BOX_SZ::Int64 = 3 # 2 to 5 feasible; box width
SUSZ::Int64 = BOX_SZ^2 # SUdoku SiZe;  board width
matrix::Matrix{Bool} = [0 0]
board::Matrix{Cell} = [Cell() Cell()]

export set_box_size, board, solve, is_valid_sudoku, set_random_solution, convert_nanoseconds

function create_base_matrix()
    global matrix = zeros(SUSZ^3, 4*SUSZ^2) # 4 types of constraint
    slice_offset::Int64 = SUSZ^2

    for r in 0:SUSZ-1
        for c in 0:SUSZ-1
            # MCx is Matrix Column for constraint x
            MC1::Int64 = r * SUSZ + c + 1 # M.Col. for this cell; +1 for Julia base 1
            B::Int64 = (div(r, BOX_SZ) * BOX_SZ) + div(c, BOX_SZ) # box number for this cell
            for v in 1:SUSZ # symbolic value (ie. {1 to 9})
                MC2::Int64 = (slice_offset * 1) + r * SUSZ + v # M.Col. for this row/value; +1 for Julia base 1
                MC3::Int64 = (slice_offset * 2) + c * SUSZ + v # M.Col. for this col/value; +1 for Julia base 1
                MC4::Int64 = (slice_offset * 3) + B * SUSZ + v # M.Col. for this box/value; +1 for Julia base 1
                MR::Int64 = (r * SUSZ + c) * SUSZ + v # M.Row; +1 for Julia base 1
 
                matrix[MR, MC1] = true
                matrix[MR, MC2] = true
                matrix[MR, MC3] = true
                matrix[MR, MC4] = true
            end
        end
    end
    exact_cover(matrix, do_check=false) # sets DancingLinks `incidence_matrix` once only; code already checked in "test_matrix.jl"
end

"""
        solve(sdm::AbstractString; verbose::Bool=false, solutions_max::Int64=1, deterministic::Bool=false)::Int64
            sdm;            A sudoku puzzle specified in a single line of text (may contain blanks).
            [verbose]       Get DancingLinks to print timings, etc.
            [solutions_max]     The maximum number of solutions for DancingLinks to search for.
            [deterministic]     true: Solve the puzzle non-randomly.

Create a new `board` populated with the 'givens' specified in arg `sdm`, and solve it;

global var `board` will be populated with the first solution found (if any).

Returns the number of solutions found; or -1 if arg `sdm` is not valid.
"""
function solve(sdm::AbstractString; verbose::Bool=false, solutions_max::Int64=1, deterministic::Bool=false)::Int64
    # BOX_SZ == 3 || println("The current mode is $(SUSZ)x$SUSZ. Call function `set_box_size(3)` to reset it to 9x9.")
    set_board_to_empty()
    populate_givens(sdm) == -1 && return -1
    stack::Vector{Int64} = populate_stack()
    DancingLinks.solve(stack, verbose=verbose, max_solutions=solutions_max, deterministic=deterministic) || return 0 # unsolvable
    fill_board(solutions[1])
    
    return length(solutions)
end

"""
        set_random_solution(; verbose::Bool=false))
            [verbose]       Get DancingLinks to print timings, etc.

Set the global var `board` to a random solution (ie. no 'givens').
"""
function set_random_solution(; verbose::Bool=false)
    set_board_to_empty()
    DancingLinks.solve(verbose=verbose)
    fill_board(solutions[1])
end

"""
        populate_givens(sdm::AbstractString)::Int64
            sdm   A sudoku puzzle specified in a single line of text (may contain blanks).

Populate global var `board` with the 'givens' specified in arg `sdm`.

Returns the number of 'givens' found; or -1 (arg `sdm` is erroneous.)
"""
function populate_givens(sdm::AbstractString)::Int64
    v = collect.(replace(sdm, " "=>""))
    r = [ Int64(c-'0') for c in v ]
    if length(r) != SUSZ^2 
        println("Skipping `populate_givens()` as the `sdm` length($(length(r))) doesn't equal $(SUSZ^2).")
        return -1 # error: skip this
    end
    r = permutedims(reshape(r, SUSZ, SUSZ))
    count = 0
    for i in eachindex(board)
        n = r[i]
        if n >= 1 && n <= SUSZ
            c = board[i]
            c.number = n
            c.is_given = true
            count += 1
        end
    end
    return count
end

"""
        populate_stack()::Vector{Int64}

The global var `board` has been populated with 'givens'.

From this create and return a list of row-indexes into the DancingLinks global var `incidence_matrix` corresponding
to the 'givens'.
"""
function populate_stack()::Vector{Int64}
    stack::Vector{Int64} = []
    for i in 0:SUSZ-1
        for j in 0:SUSZ-1
            cell::Cell = board[i+1, j+1]
            cell.is_given && push!(stack, get_matrix_row(cell.number, i, j))
        end
    end
    return stack
end

get_matrix_row(value, row, column)::Int64 = (row * SUSZ + column) * SUSZ + value # +1 for Julai base 1

"""
        fill_board(stack::Vector{Int64})
            stack   A list if row-indexes into the DancingLinks 'incidence matrix'.
    
Convert each row-index in `stack` to global var `board` row, column and number values.
"""
function fill_board(stack::Vector{Int64})
    for matrix_row in stack
        row, column, value = get_sudoku_values(matrix_row)
        cell::Cell = board[row, column]
        set_number(cell, value)
    end
end

"""
        get_sudoku_values(matrix_row::Int64)::Tuple{Int64, Int64, Int64} -> row, column, value
            matrix_row      An index, base 1, into the DancingLinks 'incidence_matrix'.

Convert `matrix_row` (NB. base 1) into and return, the row-index (base 1), column-index (base 1) and sudoku number for the
`board`'s cell.
"""
function get_sudoku_values(matrix_row::Int64)::Tuple{Int64, Int64, Int64}
    matrix_row -= 1 # to base 0
    row::Int64 = div(matrix_row, SUSZ^2)
    column::Int64 = div(matrix_row, SUSZ) - row * SUSZ
    value::Int64 = matrix_row - (row * SUSZ + column) * SUSZ + 1

    return (row+1, column+1, value)
end

"""
        is_valid_sudoku()::Bool

Test the solution's global var `board` to see if it is a valid Sudoku solution or not.
"""
function is_valid_sudoku()::Bool
    set = Set{Int64}()
    # test rows
    for r in 1:SUSZ
        for c in 1:SUSZ
            num::Int64 = board[r, c].number
            num >=1 && num <= SUSZ && push!(set, num)
        end
        length(set) == SUSZ || return false
        empty!(set)
    end
    # test columns
    empty!(set)
    for c in 1:SUSZ
        for r in 1:SUSZ
            num::Int64 = board[r, c].number
            num >=1 && num <= SUSZ && push!(set, num)
        end
        length(set) == SUSZ || return false
        empty!(set)
    end
    # test boxes
    empty!(set)
    for b in 0:SUSZ-1
        colix = (b % BOX_SZ) * BOX_SZ # 0,3,6
        rowix = div(b, BOX_SZ) * BOX_SZ # 0,3,6
        for c in colix+1:colix+BOX_SZ
            for r in rowix+1:rowix+BOX_SZ
                num::Int64 = board[r, c].number
                num >=1 && num <= SUSZ && push!(set, num)
            end
        end
        length(set) == SUSZ || return false
        empty!(set)
    end
    return true
end

"""
        set_box_size(w::Integer)
            w       A value that will be adjusted to {2 to 5}.

Set globals `BOX_SZ`, `SUSZ` and `matrix` the incidence matrix (passed to DancingLinks).
"""
function set_box_size(w::Integer)
    w = min(5, max(2, w))
    global BOX_SZ = w; global SUSZ = w^2
    create_base_matrix()
end

"""
        set_board_to_empty()

Set the global `board` to a new Matrix of empty Cells.
"""
function set_board_to_empty()
    global board = Matrix{Cell}(undef, SUSZ, SUSZ)
    for i in 1:SUSZ^2
        board[i] = Cell()
    end
end

"""
        to_string(brd::Matrix{Cell})::String
            brd     A Sudoku2 board to represent.

Return the string representation of `brd`.
"""
function Base.string(brd::Matrix{Cell})::String
    io = IOBuffer()
    nc = 29 # for BOX_SZ=3
    BOX_SZ == 2 && (nc = 13)
    BOX_SZ == 4 && (nc = 67)
    BOX_SZ == 5 && (nc = 104)
    hor_line = '-'^nc
    for i in 0:SUSZ-1
        i % BOX_SZ == 0 && println(io, hor_line)
        for j in 0:SUSZ-1
            j % BOX_SZ == 0 && j > 0 && print(io, '|')
            print(io, string(brd[i+1, j+1]))
        end
        println(io)
    end
    println(io, hor_line)
    return String(take!(io))
end

end # module Sudoku2

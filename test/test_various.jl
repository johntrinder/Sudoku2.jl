using Sudoku2

const VERY_HARD =  "100000002 090400050 006000700 050903000 000070000 000850040 700000600 030009080 002000001" # 21 givens, spaces will be removed
const UNSOLVABLE = "000080593 009100000 007000000 805000000 702000804 000000107 000000700 000008400 364050004" # 23 givens, spaces will be removed
const PUZZLES = "17puz49158.txt"

set_box_size(3)

function test_sdm(filename::AbstractString)
    println("Testing puzzles. This will take approximately 2 min ...")
    tm = time_ns()
    sdm_errors::Int64 = 0
    invalid_sudokus::Int64 = 0
    unsolvable::Int64 = 0
    lines = readlines(filename)
    for sdm in lines
        n = solve(sdm)
        if n == -1
            sdm_errors += 1
        elseif n == 0
            unsolvable += 1
            is_valid_sudoku() && (invalid_sudokus += 1)
        end
    end
    tm = time_ns() - tm
    println("Reading all 'sdm' format Sudoku puzzles from the file '$filename'.")
    println("Total N puzzles = $(length(lines))")
    println("N unsolvable puzzles = $unsolvable")
    println("N erroneous puzzles in the file = $sdm_errors")
    println("N non-valid sudoku solutions found = $invalid_sudokus")
    println("Time taken = $(convert_nanoseconds(tm, units=:sec))") # got 1 min 22 sec
end

function test_very_hard()
    # the C# version regularly took 6.5 to 7.5 msec - this takes from 5.5 msec upwards
    println("Solving 'VERY_HARD'")
    solve(VERY_HARD, verbose=true, deterministic=true, solutions_max=1)
    println("Valid Sudoku solution? = $(is_valid_sudoku())")
    println(string(board))
end

function test_unsolvable()
    println("Solving 'UNSOLVABLE'")
    solve(UNSOLVABLE, verbose=true)
    println(string(board))
end

function test_set_random_9x9_solution()
    N=2
    println("$N random solutions (no 'givens')\n")
    for _ in 1:N
        set_random_solution(verbose=true)
        println("Valid Sudoku solution? = $(is_valid_sudoku())")
        println(string(board))
    end
end

function test_set_random_4x4_solution()
    set_box_size(2)
    N=2
    println("$N random solutions (no 'givens')\n")
    for _ in 1:N
        set_random_solution(verbose=true)
        println("Valid Sudoku solution? = $(is_valid_sudoku())")
        println(string(board))
    end
    set_box_size(3)
end

function test_set_random_16x16_solution()
    set_box_size(4)
    N=2
    println("$N random solutions (no 'givens')\n")
    for _ in 1:N
        set_random_solution(verbose=true)
        println("Valid Sudoku solution? = $(is_valid_sudoku())")
        println(string(board))
    end
    set_box_size(3)
end

test_very_hard()
test_unsolvable()
test_set_random_4x4_solution()
test_set_random_9x9_solution()
test_set_random_16x16_solution()
# test_sdm(joinpath(@__DIR__, PUZZLES)) # takes about 1.5 min

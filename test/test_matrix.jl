using DancingLinks, Sudoku2
import Sudoku2: *

const SU = Sudoku2
const DL = DancingLinks

set_box_size(3)

N::Int64 = 1_000 # N = 1_000_000 took 42 min resulting in 1_000_000 unique random solutions
sols::Vector{Vector{Int64}} = []
tm = time_ns()
for _ in 1:N
    DL.solve() && push!(sols, DL.solutions[1])
end
tm = time_ns() - tm
println("Iterating $N times took $(convert_nanoseconds(tm, units=:ms))")
println("N random solutions found = $(length(sols))")
println("N solutions NOT unique = $(length(sols) - length(unique(sols)))")

c = 0
for s in sols
    length(s) != SU.SUSZ^2 && (global c += 1)
end
println("N solutions of incorrect size(!= $(SU.SUSZ^2)) = $c")
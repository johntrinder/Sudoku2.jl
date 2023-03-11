
mutable struct Cell
    number::Integer
    is_given::Bool
end
Cell() = Cell(0, false)

"""
        set_number(cell::Cell, num::Integer)

Set `cell`s number. Doesn't set the cell if it is a 'given'.
"""
function set_number(cell::Cell, num::Integer)
    cell.is_given && return
    cell.number = num
end

"""
        string(cell::Cell)::String
"""
function string(cell::Cell)::String
    flg = BOX_SZ <= 3
    num = cell.number
    numstr::String = flg ? Base.string(num) : lpad(num, 2)
    if cell.is_given
        s::String = "($numstr)"
    elseif num > 0
        s = " $numstr "
    else
        s = flg ? " - " : " -- "
    end
    return s
end
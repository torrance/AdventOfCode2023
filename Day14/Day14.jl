puzzle = stack(map(readlines("input.txt")) do line
    return collect(line)
end, dims=1)

function shiftuprow!(puzzle)
    changed::Bool = false
    @views for (row, rowup) in zip(eachrow(puzzle[2:end, :]), eachrow(puzzle))
        for i in eachindex(row)
            if row[i] == 'O' && rowup[i] == '.'
                changed = true
                row[i] = '.'
                rowup[i] = 'O'
            end
        end
    end

    return changed
end

shiftnorth!(puzzle) = while shiftuprow!(puzzle); end
shiftsouth!(puzzle) = @views while shiftuprow!(puzzle[end:-1:begin, :]); end

function shiftwest!(puzzle)
    puzzle .= permutedims(puzzle)
    while shiftuprow!(puzzle); end
    puzzle .= permutedims(puzzle)
end

function shifteast!(puzzle)
    puzzle .= permutedims(puzzle)
    while @views shiftuprow!(puzzle[end:-1:begin, :]); end
    puzzle .= permutedims(puzzle)
end

# Part 1
puzzle1 = copy(puzzle)
shiftnorth!(puzzle1)
part1 = sum(enumerate(reverse(eachrow(puzzle1)))) do (i, row)
    return i * sum(==('O'), row)
end
println("Part 1: ", part1)

# Part 2
puzzle2 = copy(puzzle)
const history = Matrix{Char}[]

while true
    shiftnorth!(puzzle2)
    shiftwest!(puzzle2)
    shiftsouth!(puzzle2)
    shifteast!(puzzle2)

    push!(history, copy(puzzle2))
    if puzzle2 in history[begin:end - 1]
        break  # We've found a cycle!
    end
end

# Based on the cycle length and initial offset, calculate the puzzle state after
# the 1000000000 spin.
idx1, idx2 = findall(==(last(history)), history)
N = idx1 + rem(1000000000 - idx1, idx2 - idx1)

part2 = sum(enumerate(reverse(eachrow(history[N])))) do (i, row)
    return i * sum(==('O'), row)
end
println("Part 2: ", part2)
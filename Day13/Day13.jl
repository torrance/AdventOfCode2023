lines = readlines("input.txt")

breaks = findall(isempty ∘ strip , lines)
pushfirst!(breaks, 0)
push!(breaks, length(lines) + 1)

patterns = map(zip(breaks, breaks[2:end])) do (idx1, idx2)
    return stack(map(collect, lines[idx1 + 1:idx2 - 1]), dims=1)
end

function isreflected(pattern, col)
    limit = min(col, size(pattern, 2) - col) - 1

    for offset in 0:limit
        if !(pattern[:, col - offset] == pattern[:, col + 1 + offset])
            return false
        end
    end
    return true
end

part1 = sum(patterns) do pattern
    nrows, ncols = size(pattern)
    for n in 1:(ncols - 1)
        if isreflected(pattern, n)
            return n
        end
    end
    pattern = permutedims(pattern)
    for n in 1:(nrows - 1)
        if isreflected(pattern, n)
            return n * 100
        end
    end
end
println("Part 1: ", part1)

function isalmostreflected(pattern, col)
    limit = min(col, size(pattern, 2) - col) - 1

    x = sum(0:limit) do offset
        return sum(pattern[:, col - offset] .!= pattern[:, col + 1 + offset])
    end
    return x == 1
end

part2 = sum(patterns) do pattern
    nrows, ncols = size(pattern)
    for n in 1:(ncols - 1)
        if isalmostreflected(pattern, n)
            return n
        end
    end
    pattern = permutedims(pattern)
    for n in 1:(nrows - 1)
        if isalmostreflected(pattern, n)
            return n * 100
        end
    end
end
println("Part 2: ", part2)
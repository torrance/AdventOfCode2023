lines = readlines("input.txt")

readings = map(lines) do line
    return map(x -> parse(Int, x), split(line))
end

function extrapolate(xs::Vector{Int})
    # Stopping condition
    if all(==(0), xs)
        return last(xs)
    end

    diff = map(zip(xs, Iterators.drop(xs, 1))) do (x1, x2)
        return x2 - x1
    end

    # Recurse to next level of diffs
    return last(xs) + extrapolate(diff)
end

part1 = sum(readings) do reading
    return extrapolate(reading)
end
println("Part 1: $(part1)")

part2 = sum(readings) do reading
    return extrapolate(reverse(reading))
end
println("Part 2: $(part2)")

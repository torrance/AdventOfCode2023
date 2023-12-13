using Memoize

lines = readlines("input.txt")

@enum State good bad unknown

inputs = map(lines) do line
    springs, code = split(line)

    springs = collect(springs)
    springs = map(springs) do char
        char == '.' ? good : (char == '#' ? bad : unknown)
    end

    code = split(code, ',')
    code = map(code) do char
        return parse(Int, char)
    end

    return springs, code
end

@memoize Dict function recurse(springs, code::Vector{Int})::Int
    # Ignore leading good springs
    idx = findfirst(!=(good), springs)

    if isnothing(idx)
        # There's no bad spring sleft; we're done
        if isempty(code)
            return true
        else
            return false
        end
    end
    springs = springs[idx:end]

    s = springs[begin]
    c = isempty(code) ? 0 : code[begin]

    if s == bad
        if length(springs) < c || @views good in springs[1:c]
            # Must be at least c bad/unknown springs remaining
            return false
        elseif length(springs) == c && length(code) == 1
            # Perfect match!
            return true
        elseif length(springs) == c && length(code) > 1
            # There's more code than we have space for
            return false
        elseif springs[c + 1] == bad
            # Each section of bad springs must be good/unknown separated
            return false
        else
            springs[c + 1] = good  # Ensure the separator is set to good
            return recurse(springs[c + 1:end], code[2:end])
        end
    else
        # Must be unknown
        @assert s == unknown

        springs[begin] = bad
        return recurse(springs, code) + recurse(springs[2:end], code)
    end
end

# Part 1
part1 = sum(inputs) do (springs, code)
    return recurse(springs, code)
end
println(part1)

# Part 2
inputs = map(inputs) do (springs, code)
    push!(springs, unknown)
    springs = repeat(springs, 5)[begin:end - 1]
    code = repeat(code, 5)
    return springs, code
end

part2 = sum(inputs) do (springs, code)
    return recurse(springs, code)
end
println(part2)
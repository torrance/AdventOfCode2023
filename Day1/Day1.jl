lines = readlines("input.txt")

# Part 1
part1 = sum(lines) do line
    numerals = map(filter(isnumeric, collect(line))) do char
        return parse(Int, char)
    end
    return numerals[begin] * 10 + numerals[end]
end

println("Part 1: $(part1)")

# Part 2
const words = Dict(
    "one" => 1, "two" => 2, "three" => 3, "four" => 4, "five" => 5,
    "six" => 6, "seven" => 7, "eight" => 8, "nine" => 9
)

part2 = sum(lines) do line
    numerals = Int[]
    for idx in eachindex(line)
        if isnumeric(line[idx])
            push!(numerals, parse(Int, line[idx]))
        else
            # We can't use a simple replace() function since, e.g. twone => 2, 1
            for word in keys(words)
                if startswith(line[idx:end], word)
                    push!(numerals, words[word])
                end
            end
        end
    end

    return numerals[begin] * 10 + numerals[end]
end

println("Part2: $(part2)")
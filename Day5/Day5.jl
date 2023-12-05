lines = readlines("input.txt")

maps = [String[]]

# Split lines based on empty spaces
for line in lines
    if isempty(line)
        push!(maps, String[])
    else
        push!(maps[end], line)
    end
end

# Seeds is the first line
seeds = map(split(only(popfirst!(maps)))[2:end]) do seed
    return parse(Int, seed)
end

# Remove titles for remaining lines
for map in maps
    popfirst!(map)
end

maps = map(maps) do _map
    map(_map) do line
        x, y, z = parse.(Int, split(line))
        return range(x, length=z), range(y, length=z)
    end
end

# Part 1
part1 = minimum(map(seeds) do x
    for map in maps
        for (dst, src) in map
            if x in src
                idx = findfirst(==(x), src)
                x = dst[idx]
                break
            end
        end
    end
    return x
end)

println("Part 1: $(part1)")

# Part 2
function getmapping(xs, src, dst)
    low = 1 + max(0, first(xs) - first(src))
    high = length(src) - max(0, last(src) - last(xs))
    return src[low:high], dst[low:high]
end

function getunmatched(xs::UnitRange{Int64}, matched::Vector{UnitRange{Int64}})
    # Sort matched by start index
    sort!(matched, by=x -> first(x))

    unmatched = UnitRange[]

    startx = first(xs)
    for m in matched
        r = startx:(first(m) - 1)
        if !isempty(r)
            push!(unmatched, r)
        end
        startx = last(m) + 1
    end

    r = startx:last(xs)
    if !isempty(r)
        push!(unmatched, r)
    end

    return unmatched
end

function mapper(maps, xs::UnitRange{Int64})
    lowest = typemax(Int)

    if isempty(maps)
        return xs[begin]
    end

    map0, rest... = maps

    # Find valid mappings of whole or partial ranges from xs
    matched = UnitRange{Int64}[]
    for (dst, src) in map0
        src, dst = getmapping(xs, src, dst)

        if !isempty(src)
            push!(matched, src)
            lowest = min(lowest, mapper(rest, dst))
        end
    end

    # Cycle through remaining matches with no Mapping
    for unmatched in getunmatched(xs, matched)
        lowest = min(lowest, mapper(rest, unmatched))
    end

    return lowest
end

seeds = map(Iterators.partition(seeds, 2)) do (low, length)
    return range(low; length)
end

part2 = minimum([mapper(maps, seed) for seed in seeds])
println("Part 2: $(part2)")
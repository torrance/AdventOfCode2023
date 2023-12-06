# Part 1
times, distances = readlines("input.txt")

times = map(split(times[12:end])) do time
    return parse(Int, time)
end

distances = map(split(distances[12:end])) do distance
    return parse(Int, distance)
end

part1 = prod(zip(times, distances)) do (time, distance)
    return count(0:time) do charge
        return (time - charge) * charge > distance
    end
end
println(part1)

# Part 2
time, distance = readlines("input.txt")
time = parse(Int, replace(time[12:end], " " => ""))
distance = parse(Int, replace(distance[12:end], " " => ""))

part2 = count(0:time) do charge
    return (time - charge) * charge > distance
end
println(part2)
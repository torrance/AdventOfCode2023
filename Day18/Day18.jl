function mkvertices(lines)
    vertices = [CartesianIndex(1, 1)]
    for (direction, N) in lines
        push!(vertices, vertices[end] + N * direction)
    end
    return vertices
end

function discretearea(vertices)::Int
    # Shoelace Formula
    area = sum(zip(vertices, vertices[2:end])) do (from, to)
        y1, x1 = Tuple(from)
        y2, x2 = Tuple(to)
        return ((x1 * y2) - (x2 * y1)) / 2
    end

    boundary = sum(zip(vertices, vertices[2:end])) do (from, to)
        y1, x1 = Tuple(from)
        y2, x2 = Tuple(to)
        return abs(x2 - x1) + abs(y2 - y1)
    end

    # Pick's formula
    interior = area - boundary / 2 + 1
    return boundary + interior
end

# Part 1
directions = Dict(
    'U' => CartesianIndex(-1, 0),
    'D' => CartesianIndex(1, 0),
    'L' => CartesianIndex(0, -1),
    'R' => CartesianIndex(0, 1),
)

lines = map(readlines("input.txt")) do line
    direction, N, _ = split(line)
    N = parse(Int, N)
    return directions[only(direction)], N
end

println("Part 1: ", discretearea(mkvertices(lines)))

# Part 2
directions = Dict(
    0 => CartesianIndex(0, 1),
    1 => CartesianIndex(1, 0),
    2 => CartesianIndex(0, -1),
    3 => CartesianIndex(-1, 0)
)

lines = map(readlines("input.txt")) do line
    _, _, code = split(line)
    code = strip(code, ['(', '#', ')'])
    N = parse(Int, code[1:5], base=16)
    return directions[parse(Int, code[6])], N
end

println("Part 2: ", discretearea(mkvertices(lines)))

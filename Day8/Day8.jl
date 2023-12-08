using StaticArrays

const Label = SVector{3, Char}

lines = readlines("input.txt")

const instructions = map(collect(popfirst!(lines))) do char
    return char == 'L' ? 1 : 2
end

const nodes = Dict{Label, Tuple{Label, Label}}()
for line in Iterators.drop(lines, 1)
    name, rest = split(line, " = ")
    left, right = split(rest, ", ")
    left, right = strip(left, '('), strip(right, ')')

    name, left, right = Label(collect(name)), Label(collect(left)), Label(collect(right))
    nodes[name] = (left, right)
end

function part1(label::Label)
    steps::Int = 0

    for instruction in Iterators.cycle(instructions)
        steps += 1;
        label = nodes[label][instruction]
        if label == Label('Z', 'Z', 'Z')
            return steps
        end
    end
end
println("Part 1: ", part1(Label('A', 'A', 'A')))

function getcycle(label::Label)
    visited = Tuple{Int, Label}[]

    steps::Int = 0
    while true
        steps += 1
        idx = mod1(steps, length(instructions))

        label = nodes[label][instructions[idx]]
        push!(visited, (idx, label))

        @views if (idx, label) in visited[begin:end - 1]
            break
        end
    end

    # Assert only one '??Z' exists
    offset = only(findall(v -> last(last(v)) == 'Z', visited))

    # Assert this equality, otherwise lcm() is not applicable
    cycle = -1 * -(findall(==(last(visited)), visited)...)
    @assert offset == cycle

    return cycle
end

part2 = lcm(map(getcycle, [l for l in keys(nodes) if last(l) == 'A'])...)
println("Part 2: $(part2)")
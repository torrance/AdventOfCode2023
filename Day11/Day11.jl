input = stack(map(collect, readlines("input.txt")), dims=1)

const galaxies = [idx for (idx, char) in pairs(input) if char == '#']

# Account for exanding rows
const expandedrows = [i for (i, row) in enumerate(eachrow(input)) if all(==('.'), row)]
const expandedcols = [i for (i, col) in enumerate(eachcol(input)) if all(==('.'), col)]

println(expandedrows)

function taxicab(g1::CartesianIndex{2}, g2::CartesianIndex{2})
    y1, x1 = Tuple(g1)
    y2, x2 = Tuple(g2)
    return abs(x1 - x2) + abs(y1 - y2)
end

function expandgalaxies(galaxies, factor)
    return map(galaxies) do galaxy
        y, x = Tuple(galaxy)
        xoffset = count(<(x), expandedcols)
        yoffset = count(<(y), expandedrows)
        return CartesianIndex(y + yoffset * (factor - 1), x + xoffset * (factor - 1))
    end
end

# Part 1
galaxies_part1 = expandgalaxies(galaxies, 2)
part1 = sum(galaxies_part1) do g1
    return sum(g2 -> taxicab(g1, g2), galaxies_part1)
end ÷ 2
println("Part 1: ", part1)

# Part 2
galaxies_part2 = expandgalaxies(galaxies, 1_000_000)
part2 = sum(galaxies_part2) do g1
    return sum(g2 -> taxicab(g1, g2), galaxies_part2)
end ÷ 2
println("Part 2: ", part2)
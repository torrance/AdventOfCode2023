mutable struct Colors
    red::Int
    green::Int
    blue::Int
end

function Base.:+(lhs::Colors, rhs::Colors)
    return Colors(
        lhs.red + rhs.red, lhs.green + rhs.green, lhs.blue + rhs.blue
    )
end

function Base.prod(c::Colors)
    return c.red * c.green * c.blue
end

lines = readlines("input.txt")

# Parse the input into vector of GameId => Colors[]
games = map(lines) do line
    gameid, rest = split(line[5:end], ":")
    gameid = parse(Int, gameid)

    game = map(split(rest, ";")) do draw
        return sum(split(draw, ",")) do colorpair
            number, color = split(strip(colorpair))
            number = parse(Int, number)

            if color == "red"
                return Colors(number, 0, 0)
            elseif color == "green"
                return Colors(0, number, 0)
            elseif color == "blue"
                return Colors(0, 0, number)
            end
        end
    end

    return gameid => game
end

# Part 1
part1 = sum(games) do (gameid, draws)
    for draw in draws
        if draw.red > 12 || draw.green > 13 || draw.blue > 14
            return 0
        end
    end
    return gameid
end
println(part1)

# Part 2
part2 = sum(games) do (gameid, game)
    colors = Colors(0, 0, 0)
    for draw in game
        colors.red = max(colors.red, draw.red)
        colors.green = max(colors.green, draw.green)
        colors.blue = max(colors.blue, draw.blue)
    end

    return prod(colors)
end
println(part2)
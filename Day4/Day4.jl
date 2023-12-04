lines = readlines("input.txt")

# Parse input in Vector of Tuple(cardid, [winning, ...], [draw, ...])
const cards = map(lines) do line
    cardid, rest = split(line, ":")

    _, cardid = split(cardid)
    cardid = parse(Int, cardid)

    winning, draw = split(rest, "|")

    winning = map(split(strip(winning))) do number
        return parse(Int, number)
    end

    draw = map(split(strip(draw))) do number
        return parse(Int, number)
    end

    return (cardid, winning, draw)
end

# Part 1
part1 = sum(cards) do (_, winning, draw)
    N = length(intersect(winning, draw))
    if N == 0
        return 0
    end
    return 2^(N -1)
end
println("Part 1: $(part1)")

# Part 2
function part2(subcards, fullcards)
    sum(subcards) do (cardid, winning, draw)
        N = length(intersect(winning, draw))

        if N == 0
            return 1
        else
            @views return 1 + part2(fullcards[cardid + 1: cardid + N], fullcards)
        end
    end
end
println("Part 2: $(part2(cards, cards))")
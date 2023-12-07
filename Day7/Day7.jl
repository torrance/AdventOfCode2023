lines = readlines("input.txt")

handbids = map(lines) do line
    hand, bid = split(line)
    return hand, parse(Int, bid)
end

# Create a lessthan function for comparing two hands,
# with configuration ofakind function and value mapping
function mklessthan(ofakind::Function, value::Dict{Char, Int})
    return function (lhs::AbstractString, rhs::AbstractString)
        lhsOfAKind = ofakind(lhs)
        rhsOfAKind = ofakind(rhs)

        # Return hand with most of a kind
        for (l, r) in zip(lhsOfAKind, rhsOfAKind)
            if l < r
                return true
            elseif l > r
                return false
            end
        end

        # Fallback: return hand with highest card
        for (l, r) in zip(lhs, rhs)
            if value[l] < value[r]
                return true
            elseif value[l] > value[r]
                return false
            end
        end
    end
end

# Part 1

const valuepart1::Dict{Char, Int} = Dict(
    '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9,
    'T' => 10, 'J' => 11, 'Q' => 12, 'K' => 13, 'A' => 14,
)

# Return ordered list (high to low) of number of duplicate cards
function ofakindpart1(str::AbstractString)
    return sort(map(unique(str)) do card
        return count(card, str)
    end, rev=true)
end

sort!(handbids, by=first, lt=mklessthan(ofakindpart1, valuepart1))
part1 = sum(enumerate(handbids)) do (i, (_, bid))
    return i * bid
end
println(part1)

# Part 2

const valuepart2::Dict{Char, Int} = Dict(
    '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9,
    'T' => 10, 'J' => 1, 'Q' => 12, 'K' => 13, 'A' => 14,
)

# Return ordered list of number of duplicate cards, but J is wild
function ofakindpart2(str::AbstractString)
    # Count duplicates, but ignore Jokers
    result = sort(map(unique(str)) do card
        return card == 'J' ? 0 : count(card, str)
    end, rev=true)

    # Add the Joker count to the highest duplicate
    result[begin] += count('J', str)

    return result
end

sort!(handbids, by=first, lt=mklessthan(ofakindpart2, valuepart2))
part1 = sum(enumerate(handbids)) do (i, (_, bid))
    return i * bid
end
println(part1)
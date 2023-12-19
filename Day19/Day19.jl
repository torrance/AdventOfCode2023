lines = readlines("input.txt")
idx = findfirst(isempty, lines)

const rulesets = Dict(map(lines[begin:idx - 1]) do line
    key, ruleset = split(line, '{')
    ruleset = strip(ruleset, '}')
    ruleset = split(ruleset, ',')
    return key => ruleset
end)

const parts = map(lines[idx + 1:end]) do line
    line = strip(line, ['{', '}'])
    return Dict(map(split(line, ',')) do keyvalue
        key, val = split(keyvalue, '=')
        return only(key) => parse(Int, val)
    end)
end

# Part 1
function isaccepted(part, ruleset)
    for rule in ruleset
        if rule == "A"
            return true
        elseif rule == "R"
            return false
        elseif ':' in rule
            c, number, action = split(rule, ['<', '>', ':'])
            c = only(c)
            number = parse(Int, number)

            if '<' in rule
                if part[c] < number
                    return isaccepted(part, [action])
                end
            elseif '>' in rule
                if part[c] > number
                    return isaccepted(part, [action])
                end
            else
                abort("Unreachable")
            end
        else
            # It's a naked label: redirect to a new ruleset
            return isaccepted(part, rulesets[rule])
        end
    end
    abort("Unreachable")
end

part1 = sum(filter(part -> isaccepted(part, rulesets["in"]), parts)) do part
    return sum(values(part))
end
println("Part 1: ", part1)

# Part 2
function search(rangemap, ruleset)
    N::Int = 0
    for rule in ruleset
        if rule == "A"
            return N + prod(length, values(rangemap))
        elseif rule == "R"
            return N + 0
        elseif ':' in rule
            c, number, action = split(rule, ['<', '>', ':'])
            c = only(c)
            number = parse(Int, number)

            # Split the rangemap into the pass/fail parts
            nextrangemap = copy(rangemap)
            if '<' in rule
                nextrangemap[c] = first(rangemap[c]):min(number - 1, last(rangemap[c]))
                rangemap[c] = max(number, first(rangemap[c])):last(rangemap[c])
            elseif '>' in rule
                nextrangemap[c] = max(number + 1, first(rangemap[c])):last(rangemap[c])
                rangemap[c] = first(rangemap[c]):min(number, last(rangemap[c]))
            else
                abort("Unreachable")
            end

            N += search(nextrangemap, [action])
        else
            # It's a naked label: redirect to a new ruleset
            return N + search(rangemap, rulesets[rule])
        end
    end
    abort("Unreachable")
end

initrangemap = Dict('x' => 1:4000, 'm' => 1:4000, 'a' => 1:4000, 's' => 1:4000)
part2 = search(initrangemap, rulesets["in"])
println("Part 2: ", part2)

codes = split(replace(read("input.txt", String), "\n" => ","), ",")

function mkhash(str)
    return foldl(str, init=0) do current, char
        current += convert(Int, char)
        current *= 17
        return current % 256
    end
end

part1 = sum(mkhash, codes)
println("Part 1: ", part1)

const Lens = Tuple{String, Int}
const boxes = [Lens[] for _ in 1:256]

foreach(codes) do code
    if '=' in code
        label, focallength = split(code, '=')
        focallength = parse(Int, focallength)
        boxid = mkhash(label) + 1

        idx = findfirst(lens -> first(lens) == label, boxes[boxid])
        if isnothing(idx)
            push!(boxes[boxid], (label, focallength))
        else
            boxes[boxid][idx] = (label, focallength)
        end
    else
        label = strip(code, '-')
        boxid = mkhash(label) + 1

        idx = findfirst(lens -> first(lens) == label, boxes[boxid])
        if !isnothing(idx)
            deleteat!(boxes[boxid], idx)
        end
    end
end

part2 = sum(enumerate(boxes)) do (boxid, box)
    sum(enumerate(box), init=0) do (lensid, (_, focallength))
        boxid * lensid * focallength
    end
end
println("Part 2: ", part2)

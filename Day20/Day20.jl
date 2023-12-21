@enum PulseType High Low
@enum ModType Broadcaster FlipFlop Conjunction Null

mutable struct Mod
    type::ModType
    children::Vector{String}
    state::Bool # for FlipFlop
    memory::Dict{String, PulseType}
end

mods = Dict(map(readlines("input.txt")) do line
    label, children = split(line, " -> ")
    children = split(children, ", ")

    local modtype::ModType
    if label == "broadcaster"
        modtype = Broadcaster
    else
        modtype = label[1] == '%' ? FlipFlop : Conjunction
        label = label[2:end]
    end

    return label => Mod(modtype, children, false, Dict{String, PulseType}())
end)

# Add any null nodes
for (label, mod) in mods
    for child in mod.children
        if !haskey(mods, child)
            mods[child] = Mod(Null, [], false, Dict())
        end
    end
end

# Populate the memory of Conjunction modules with Low pulses
for (label, mod) in mods
    for child in mod.children
        if mods[child].type == Conjunction
            mods[child].memory[label] = Low
        end
    end
end

function pulsate!(mods, fn=identity)
    pulses = Tuple{Pair{String, String}, PulseType}[("button" => "broadcaster", Low)]

    Nlow, Nhigh = 0, 0

    while !isempty(pulses)
        # For part 2: allow a function to track pulses
        fn(first(pulses))

        (src, dst), pulse = popfirst!(pulses)
        if pulse == Low
            Nlow +=1
        else
            Nhigh += 1
        end

        mod = mods[dst]
        if mod.type == Broadcaster
            # Resend the same pulse to children
            for child in mod.children
                push!(pulses, (dst => child, pulse))
            end
        elseif mod.type == FlipFlop
            # Send pulse only if Low pulse received
            if pulse == Low
                mod.state = !mod.state
                nextpulse = mod.state ? High : Low
                for child in mod.children
                    push!(pulses, (dst => child, nextpulse))
                end
            end
        elseif mod.type == Conjunction
            # Send a Low pulse to all children if the last pulse from all children was High
            # Otherwise, send Low
            mod.memory[src] = pulse  # Update memory for this source
            nextpulse = High
            if all(==(High), values(mod.memory))
                nextpulse = Low
            end

            # println("loading up pulse from $(dst) with pulse type ($nextpulse)")
            for child in mod.children
                push!(pulses, (dst => child, nextpulse))
            end
        end
    end

    return Nlow, Nhigh
end

# Part 1
mods_part1 = deepcopy(mods)
part1 = prod(sum(1:1000) do _
   [pulsate!(mods_part1)...]
end)
println("Part 1: ", part1)

# Part 2

function getparents(label)
    return findall(mods) do mod
        return label in mod.children
    end
end

parent = only(getparents("rx"))
grandparents = getparents(parent)
@assert length(grandparents) > 1

# Create cycles dictionary to detect cycles for each of the grandparents
cycles = Dict([label => Int[] for label in grandparents])

for N in Iterators.countfrom(1)
    fn = function(pulse)
        (src, dst), pulsetype = pulse
        if pulsetype == High && src in grandparents && dst == parent
            push!(cycles[src], N)
        end
    end

    pulsate!(mods, fn)

    if all(x -> length(x) >= 4, values(cycles))
        break
    end
end

# Find the lowest common multuple, giving the first time all 4 grandparents
# are simultaneously High
part2 = lcm(map(first, values(cycles))...)
println("Part 2: ", part2)

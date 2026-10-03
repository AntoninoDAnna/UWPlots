mutable struct Cycler
    val
    next
    Cycler(val...) = new(val,1)
end

function next(c::Cycler)
    v = c.val[c.next]
    c.next = c.next%length(c.val) + 1
    return v
end

function get_at(c::Cycler,i::Int64)
    idx = (i-1)%length(c.val) +1
    return c.val[idx]
end

Markers = Cycler("s","<",">","v","^","d","*","p")

next_marker() = next(Markers)
get_marker(i::Int64) = get_at(Markers,i)

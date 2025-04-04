struct HeaderParser{K,V,R} <: AbstractDict{K,V}
    parsed::Dict{K,V}
    raw::Dict{K,R}
end

Base.length(hp::HeaderParser) = length(hp.parsed) + length(hp.raw)

function Base.iterate(hp::HeaderParser)
    iter = iterate(hp.parsed)
    if isnothing(iter)
        return nothing
    end
    item, state = iter
    item, (:parsed, state)
end

function Base.iterate(hp::HeaderParser, (dict, state))
    if !isnothing(state)
        item, next = iterate(getfield(hp, dict), state)
        return item, (dict, next)
    end
    if dict == :raw
        nothing
    end
    iter = iterate(hp.raw)
    if isnothing(iter)
        return nothing
    end
    item, state = iter
    item, (:raw, state)
end

function Base.setindex!(hp::HeaderParser, value, key)
    if haskey(hp.raw, key)
        hp.raw[key] *= value
    else
        hp.raw[key] = value
    end
end

function Base.getindex(hp::HeaderParser, key)
    get!(hp.parsed, key) do
        parser = get(SPECIFIC_PARSERS, key, parse_default)
        parser(hp.raw[key])
    end
end

Base.haskey(hp::HeaderParser, key) = haskey(hp.parsed, key) || haskey(hp.raw, key)

function Base.get(hp::HeaderParser, key, default)
    get(hp.parsed, key) do
        parser = get(SPECIFIC_PARSERS, key, parse_default)
        haskey(hp.raw, key) ? parser(hp.raw[key]) : default
    end
end

function Base.get!(hp::HeaderParser, key, default)
    get!(hp.parsed, key) do
        parser = get(SPECIFIC_PARSERS, key, parse_default)
        haskey(hp.raw, key) ? parser(hp.raw[key]) : default
    end
end

function Base.getkey(hp::HeaderParser, key, default)
    if haskey(hp.parsed, key)
        return getkey(hp.parsed, key, default)
    end
    getkey(hp.raw, key, default)
end

function Base.delete!(hp::HeaderParser, key)
    delete!(hp.parsed, key)
    delete!(hp.raw, key)
    hp
end

function Base.pop!(hp::HeaderParser, key)
    if haskey(hp.parsed, key)
        return pop!(hp.parsed, key)
    end
    pop!(hp.raw, key)
end

function Base.pop!(hp::HeaderParser, key, default)
    if haskey(hp.parsed, key)
        return pop!(hp.parsed, key, default)
    end
    pop!(hp.raw, key, default)
end

Base.keys(hp::HeaderParser) = union(keys(hp.parsed), keys(hp.raw))
Base.values(hp::HeaderParser) = values(hp.parsed)

function tryparse_number(token::AbstractString)
    parsed = tryparse(Int, token)
    !isnothing(parsed) && return parsed
    parsed = tryparse(Float64, token)
    !isnothing(parsed) && return parsed
    token
end

function parse_default(str::AbstractString)
    parsed = tryparse_number.(split(str))

    if all(typeof.(parsed) .<: AbstractString)
        return join(parsed, " ")
    end

    length(parsed) == 0 ? nothing :
    length(parsed) == 1 ? first(parsed) :
    all(typeof.(parsed) .<: Integer) ? Vector{Int}(parsed) :
    all(typeof.(parsed) .<: Float64) ? Vector{Float64}(parsed) :
    parsed
end

function parse_created(line::AbstractString)
    date, time = split(line)
    dt = DateTime(Date(date, dateformat"d-u-y"), Time(time))
    Dict("CREATED" => dt)
end

function parse_lowtemp(line::AbstractString)
    m = match(r"(.*)TEMP:(.*)", line)
    if isnothing(m)
        Dict("LOWTEMP" => parse_default(line))
    else
        Dict(
            "LOWTEMP" => parse_default(m[1]),
            "TEMP" => parse_default(m[2])
        )
    end
end

function parse_cfr(line::AbstractString)
    m = match(r"HDR:(.*)IMG:(.*)", line)
    Dict("CFR" => parse_default.(m.captures))
end

const SPECIFIC_PARSERS = Dict(
    "CREATED" => parse_created,
    "LOWTEMP" => parse_lowtemp,
    "CFR" => parse_cfr
)

function parse_header_key(header::AbstractDict, key::AbstractString)
    parser = key in keys(SPECIFIC_PARSERS) ? SPECIFIC_PARSERS[key] : parse_default
    parser(header[key])
end

Base.@kwdef struct HeaderParser <: AbstractDict
    raw::Dict = Dict()
    parsed::Dict = Dict()
end

Base.haskey(hp::HeaderParser) = haskey(hp.raw) || haskey(hp.parsed)

function Base.setindex!(hp::HeaderParser, value::AbstractString, key)
    if haskey(hp.raw, key)
        hp.raw[key] *= value
    else
        hp.raw[key] = value
    end
end

function Base.getindex(hp::HeaderParser, key)
    if haskey(hp.parsed, key)
        return parsed[key]
    end
    parsed[key] = parse_header_key(raw, key)
end

function merge!(hp::HeaderParser, others::HeaderParser...)
    merge!(hp.raw, others.raw)
    merge!(hp.parsed, others.parsed)
end

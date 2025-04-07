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
    length(parsed) == 1 ? only(parsed) :
    all(typeof.(parsed) .<: Integer) ? Vector{Int}(parsed) :
    all(typeof.(parsed) .<: Float64) ? Vector{Float64}(parsed) : parsed
end

function parse_created(line::AbstractString)
    date, time = split(line)
    DateTime(Date(date, dateformat"d-u-yyyy"), Time(time, dateformat"HH:MM:SS"))
end

function parse_cfr(line::AbstractString)
    m = match(r"HDR:(.*)IMG:(.*)", line)
    parse_default.(m.captures)
end

const SPECIFIC_PARSERS = Dict("CREATED" => parse_created, "CFR" => parse_cfr)

struct SfrmHeaderParser{K,P,R}
    parsed::Dict{K,P}
    raw::Dict{K,R}
end

SfrmHeaderParser(nblocks::Integer) =
    SfrmHeaderParser(sizehint!(Dict{String,Any}(), nblocks), Dict{String,Any}())

function Base.setindex!(hp::SfrmHeaderParser, value, key)
    if haskey(hp.raw, key)
        hp.raw[key] *= value
    else
        hp.raw[key] = value
    end
end

function Base.getindex(hp::SfrmHeaderParser, key)
    get!(hp.parsed, key) do
        parser = get(SPECIFIC_PARSERS, key, parse_default)
        parser(hp.raw[key])
    end
end

Base.haskey(hp::SfrmHeaderParser, key) = haskey(hp.parsed, key) || haskey(hp.raw, key)

function Base.merge!(hp::SfrmHeaderParser, others::SfrmHeaderParser...)
    merge!(hp.parsed, getfield.(others, :parsed)...)
    merge!(hp.raw, getfield.(others, :raw)...)
end

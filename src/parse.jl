"""
    isunknown(line::AbstractString)

Returns if data supposed to be in `line` is unknown.
"""
function isunknown(line::AbstractString)
    any(strip(line) .== [
        "Unknown",
        "UNKNOWN",
        "None",
        "NONE"
    ])
end

"""
    tryparse_number(token::AbstractString)

Tries to parse `token` as `Int` and `Float64` and returns `token` string if unsucceed.
"""
function tryparse_number(token::AbstractString)
    parsed = tryparse(Int, token)
    !isnothing(parsed) && return parsed
    parsed = tryparse(Float64, token)
    !isnothing(parsed) && return parsed
    token
end

"""
    parse_default(str::AbstractString)

Applies `tryparse_number` to all separate elemnts of `str` and combine them in intuitively in arrays.
"""
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

"""
    parse_created(line::AbstractString)

Parses sfrm-specific datetime format.
"""
function parse_created(line::AbstractString)
    date, time = split(line)
    DateTime(Date(date, dateformat"d-u-yyyy"), Time(time, dateformat"HH:MM:SS"))
end

function parse_lowtemp(line::AbstractString)
    parsed = parse_default.(split(line))
    parsed[1] = Bool(parsed[1])
    if length(parsed) > 4
        deleteat!(parsed, 4)
    end
    parsed
end

function parse_cfr(line::AbstractString)
    m = match(r"HDR:(.*)IMG:(.*)", line)
    parse_default.(m.captures)
end

"""
    SPECIFIC_PARSERS

Dictionary contains parser functions for specific keys in sfrm file.
"""
const SPECIFIC_PARSERS =
    Dict("CREATED" => parse_created, "LOWTEMP" => parse_lowtemp, "CFR" => parse_cfr)

function parse_line(key::AbstractString, line::AbstractString)
    if isunknown(line)
        return nothing
    end
    parser = get(SPECIFIC_PARSERS, key, parse_default)
    parser(line)
end

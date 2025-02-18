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

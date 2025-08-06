"""
    AbstractBrukerImage 

Abstract supertipe of all (currently only 2) compressed bruker image types.
"""
abstract type AbstractBrukerImage end

"""
    BrukerImage86{D<:Unsigned} <: AbstractBrukerImage 

Struct that contains raw compressed image data from version 86 sfrm file.
"""
struct BrukerImage86{D<:Unsigned} <: AbstractBrukerImage 
    data::Vector{D}
    over::String
end

"""
    BrukerImage100{D<:Unsigned,U<:Signed} <: AbstractBrukerImage 

Struct that contains raw compressed image data from version 100 sfrm file.
"""
struct BrukerImage100{D<:Unsigned,U<:Signed} <: AbstractBrukerImage 
    data::Vector{D}
    under::Vector{U}
    over1::Vector{UInt16}
    over2::Vector{Int32}
    baseline::Integer
end

"""
    compress_86(img::AbstractArray{T}; dtype = UInt8) where {T<:Integer}

Compresses image to sfrm version 86 format and returns `BrukerImage86`.
"""
function compress_86(img::AbstractArray{T}; dtype = UInt8) where {T<:Integer}
    data = zeros(dtype, length(img))
    over = ""
    for (pos, val) in enumerate(img)
        data[pos] = clamp(val, dtype)
        if val != clamp(val, dtype)
            over *= @sprintf("%8d%8d", pos, val)
        end
    end
    BrukerImage86(data, over)
end

"""
    compress_100(img::AbstractArray; dtype = UInt8, utype = Int8, baseline = 64)

Compresses image to sfrm version 100 format and returns `BrukerImage100`.
"""
function compress_100(
    img::AbstractArray{T};
    dtype = UInt8,
    utype = Int8,
    baseline = 64,
) where {T<:Integer}
    data = zeros(dtype, length(img))
    under = utype[]
    over1 = UInt16[]
    over2 = Int32[]
    for (pos, val) in enumerate(img)
        if val ≤ baseline
            push!(under, val)
            data[pos] = 0
            continue
        end
        val -= baseline
        data[pos] = clamp(val, dtype)
        if val ≥ typemax(dtype)
            push!(over1, clamp(val, UInt16))
            if val ≥ typemax(UInt16)
                push!(over2, val)
            end
        end
    end
    BrukerImage100(data, under, over1, over2, baseline)
end

function decompress(comp::BrukerImage86)
    img = Int32.(comp.data)
    for i = 1:(sizeof(comp.over)/16)
        val = parse(Int32, comp.over[i:(i+7)])
        pos = parse(Int, comp.over[(i+8):(i+15)])
        img[pos] = val
    end
    img
end

function decompress(comp::BrukerImage100{D}) where {D}
    img = Int32.(comp.data)
    if !isempty(comp.over1)
        img[img .== typemax(D)] = comp.over1
    end
    if !isempty(comp.over2)
        img[img .== typemax(UInt16)] = comp.over2
    end
    if !isempty(comp.under)
        img .+= comp.baseline
        img[img .== comp.baseline] = comp.under
    end
    img
end

@doc""" 
    decompress(comp::AbstractBrukerImage)

Return decompressed image from `comp`.
""" decompress


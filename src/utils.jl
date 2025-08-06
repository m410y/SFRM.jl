"""
    unsigned_integer(bpp::Integer)

Returns unsigned integer type with corresponing size in bytes.
"""
function unsigned_integer(bpp::Integer)
    bpp == 1 ? UInt8 :
    bpp == 2 ? UInt16 :
    bpp == 4 ? UInt32 :
    bpp == 8 ? UInt64 : bpp == 16 ? UInt128 : throw(ArgumentError("wrong bytes per pixel"))
end

"""
    signed_integer(bpp::Integer)

Returns signed integer type with corresponing size in bytes.
"""
function signed_integer(bpp::Integer)
    bpp == 1 ? Int8 :
    bpp == 2 ? Int16 :
    bpp == 4 ? Int32 :
    bpp == 8 ? Int64 : bpp == 16 ? Int128 : throw(ArgumentError("wrong bytes per pixel"))
end

"""
    read_aligned_array(io::IO, type::Type{<:Integer}, length::Integer)

Reads `length` elements of `type` from `io` and skip bytes to satisfy data alignment.
"""
function read_aligned_array(io::IO, type::Type{<:Integer}, length::Integer)
    if length ≤ 0
        return type[]
    end
    data = zeros(type, length)
    read!(io, data)
    skip(io, -rem(sizeof(data), DATA_ALIGNMENT, RoundUp))
    data
end

"""
    write_aligned_array(io::IO, arr::AbstractArray)

Writes `arr` in `io` and fill needed zeros to satisfy data alignment.
"""
function write_aligned_array(io::IO, arr::AbstractArray)
    write(io, arr, zeros(UInt8, -rem(sizeof(arr), DATA_ALIGNMENT, RoundUp)))
end

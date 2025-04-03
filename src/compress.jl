function write_image_86(io::IO, img::AbstractArray{T}, data_bpp::Integer) where {T<:Integer}
    dtype = unsigned_integer(data_bpp)
    data = dtype[]
    over = UInt16[]
    for (pos, val) in enumerate(img)
        clamped = clamp(val, dtype)
        push!(data, clamped)
        if val != clamped
            push!(over, unsafe_load(Ptr{UInt16}(@sprintf("%8d%8d", ), pos, val), 1))
        end
    end
    write_aligned_array(data)
    write_aligned_array(over)
end

function write_image_100(io::IO, img::AbstractArray{T}, data_bpp::Integer, under_bpp::Integer, baseline::Integer) where {T<:Integer}
    dtype = unsigned_integer(data_bpp)
    utype = signed_integer(under_bpp)
    data = dtype[]
    under = utype[]
    over1 = UInt16[]
    over2 = Int32[]
    for val in img
        if val < baseline
            push!(under, val)
            push!(data, 0)
            continue
        end
        val -= baseline
        clamped = clamp(val, dtype)
        push!(data, clamped)
        if val != clamped
            clamped1 = clamp(val, UInt16)
            push!(over1, clamped1)
            if val != clamped1
                push!(over2, val)
            end
        end
    end
    write_aligned_array(io, data)
    write_aligned_array(io, under)
    write_aligned_array(io, over1)
    write_aligned_array(io, over2)
end

function read_image_86(
        io::IO,
        rows::Integer,
        cols::Integer,
        data_bpp::Integer,
        over_len::Integer
)
    img = read_aligned_array(io, unsigned_integer(data_bpp), rows * cols)
    for _ in 1:over_len
        over_chunk = zeros(UInt8, 16)
        read!(io, over_chunk)
        value = parse(Int, String(over_chunk[1:9]))
        pos = parse(Int, String(over_chunk[10:16]))
        img[pos] = value
    end
    img
end

function read_image_100(
        io::IO,
        rows::Integer,
        cols::Integer,
        data_bpp::Integer,
        under_bpp::Integer,
        under_len::Integer,
        over1_len::Integer,
        over2_len::Integer,
        baseline::Integer
)
    img = read_aligned_array(io, unsigned_integer(data_bpp), rows * cols)
    under = read_aligned_array(io, signed_integer(under_bpp), under_len)
    over1 = read_aligned_array(io, UInt16, over1_len)
    over2 = read_aligned_array(io, Int32, over2_len)

    img = Int32.(img)
    if !isempty(over1)
        img[img .== typemax(UInt8)] = over1
    end
    if !isempty(over2)
        img[img .== typemax(UInt16)] = over2
    end
    if !isempty(under)
        img .+= baseline
        img[img .== baseline] = under
    end
    img
end

function read_image(io::IO, header::AbstractDict)
    version = header["FORMAT"]
    rows = header["NROWS"][1]
    cols = header["NCOLS"][1]

    image = if version == 86
        read_image_86(io, rows, cols, header["NPIXELB"], header["NOVERFL"])
    elseif version == 100
        read_image_100(
            io,
            rows,
            cols,
            header["NPIXELB"]...,
            header["NOVERFL"]...,
            header["NEXP"][3]
        )
    else
        error("Unknown sfrm format version $(version)")
    end

    if "LINEAR" in keys(header)
        slope = header["LINEAR"][1]
        offset = header["LINEAR"][2]
        if slope != 1 || offset != 0
            image = image * slope + offset
        end
    end
    reshape(image, cols, rows)
end

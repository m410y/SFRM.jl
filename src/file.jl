struct SiemensFrame
    image::AbstractArray
    format::Integer
    type::AbstractString
    filename::AbstractString
    created::DateTime
    time::Number
    angles::AbstractVector
    target::AbstractString
    voltage::Number
    current::Number
    distance::Number
    axis::Integer
    increment::Number
    pixel::Number
end

SiemensFrame(image::AbstractArray, header) = SiemensFrame(
    image,
    header["FORMAT"],
    header["TYPE"],
    header["FILENAM"],
    header["CREATED"],
    header["CUMULAT"],
    header["ANGLES"],
    header["TARGET"],
    header["SOURCEK"],
    header["SOURCEM"],
    10 * header["DISTANC"][2],
    header["AXIS"],
    header["INCREME"],
    5120 / header["NROWS"][1] / header["DETTYPE"][2],
)

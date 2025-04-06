struct SiemensFrame
    image::AbstractArray
    type::AbstractString
    filename::AbstractString
    created::DateTime
    time::Number
    angles::AbstractVector
    target::AbstractString
    voltage::Number
    current::Number
    distance::Number
    wavelengths::AbstractVector
    axis::Integer
    increment::Number
end

SiemensFrame(image::AbstractArray, header) = SiemensFrame(
    image,
    header["TYPE"],
    header["FILENAM"],
    header["CREATED"],
    header["CUMULAT"],
    header["ANGLES"],
    header["TARGET"],
    header["SOURCEK"],
    header["SOURCEM"],
    10 * header["DISTANC"][2],
    header["WAVELEN"],
    header["AXIS"],
    header["INCREME"],
)

function Base.show(io::IO, ::MIME"text/plain", sfrm::SiemensFrame)
    println(io, "SiemensFrame:")
    println(io, "  ", summary(sfrm.image))
    println(io, "  general:")
    println(io, "    type: ", sfrm.type)
    println(io, "    filename: ", sfrm.filename)
    println(io, "    created: ", sfrm.created)
    println(io, "  setting:")
    println(io, "    time: ", sfrm.time, " s")
    println(io, "    distance: ", sfrm.distance, " mm")
    println(io, "    angles: ", sfrm.angles)
    if sfrm.increment != 0
        println(io, "    axis: ", sfrm.axis)
        println(io, "    increment: ", sfrm.increment)
    end
    println(io, "  source:")
    println(io, "    target: ", sfrm.target)
    println(io, "    wavelengths: ", sfrm.wavelengths, " Å")
    println(io, "    voltage: ", sfrm.voltage, " kV")
    print(io, "    current: ", sfrm.current, " mA")
end

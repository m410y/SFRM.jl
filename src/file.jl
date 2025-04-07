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
    println(io, "    voltage: ", sfrm.voltage, " kV")
    print(io, "    current: ", sfrm.current, " mA")
end

function issamesetting(
    sfrm1::SiemensFrame,
    sfrm2::SiemensFrame;
    angle = 1e-4,
    distance = 1e-3,
    voltage = 1e-3,
    current = 1e-2,
)
    size(sfrm1.image) == size(sfrm2.image) &&
        sfrm1.type == sfrm2.type &&
        sfrm1.target == sfrm2.target &&
        sfrm1.axis == sfrm2.axis &&
        all(isapprox.(sfrm1.angles, sfrm2.angles, atol = angle)) &&
        isapprox(sfrm1.distance, sfrm2.distance, atol = distance) &&
        isapprox(sfrm1.increment, sfrm2.increment, atol = angle) &&
        isapprox(sfrm1.voltage, sfrm2.voltage, atol = voltage) &&
        isapprox(sfrm1.current, sfrm2.current, atol = current)
end

function Base.:+(sfrm1::SiemensFrame, sfrm2::SiemensFrame)
    @assert issamesetting(sfrm1, sfrm2)
    k = sfrm1.time / (sfrm1.time + sfrm2.time)
    SiemensFrame(
        sfrm1.image + sfrm2.image,
        sfrm1.type,
        _same_beginning(sfrm1.filename, sfrm2.filename) * "sum.sfrm",
        min(sfrm1.created, sfrm2.created),
        sfrm1.time + sfrm2.time,
        _weighted_sum(sfrm1.angles, sfrm2.angles, k),
        sfrm1.target,
        _weighted_sum(sfrm1.voltage, sfrm2.voltage, k),
        _weighted_sum(sfrm1.current, sfrm2.current, k),
        _weighted_sum(sfrm1.distance, sfrm2.distance, k),
        sfrm1.axis,
        _weighted_sum(sfrm1.increment, sfrm2.increment, k),
    )
end

_weighted_sum(x, y, k) = x == y ? x : k * x + (1 - k) * y

function _same_beginning(str1::String, str2::String)
    i = findfirst(collect(zip(str1, str2))) do (c1, c2)
        c1 != c2
    end
    splitext(isnothing(i) ? str1 : str1[1:i-1])[1]
end

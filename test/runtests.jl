using Test
using SFRM
using Dates
using OffsetArrays

include("Aqua.jl")

const frames_folder = "./testframes"

@testset "loading" begin
    for file in readdir(frames_folder, join = true)
        @test_nowarn SFRM.load(file)
    end
end

@testset "saving" begin
    dir = tempdir()
    for file in readdir(frames_folder, join = true)
        sfrm = SFRM.load(file)
        @test_nowarn SFRM.save(joinpath(dir, sfrm.filename), sfrm)
    end
end

@testset "getproperty" begin
    fname = "mo_LaB6_2_m8_m3_friedel_129f_MP96p95_03_0001.sfrm"
    angles = [263.05, 39.10001, 10.9998, 54.7112]
    sfrm = SFRM.load(joinpath(frames_folder, fname))
    @test sfrm.image[167, 165] == 91
    @test sfrm.image[840, 237] == 4520
    @test sfrm.type == "SCAN FRAME"
    @test sfrm.filename == fname
    @test sfrm.created == DateTime(2024, 02, 23, 10, 24, 01)
    @test sfrm.time == 600.0
    @test sfrm.angles == angles
    @test sfrm.axis == 2
    @test sfrm.increment == 4.0
    @test sfrm.target == "Mo"
    @test sfrm.voltage == 50.0
    @test sfrm.current == 1.399758
    @test sfrm.distance == 12.85334
    @test sfrm.tth == angles[1]
    @test sfrm.omega == angles[2]
    @test sfrm.phi == angles[3]
    @test sfrm.chi == angles[4]
    @test sfrm.pix512percm == 36.954918
    @test sfrm.lambdaKα == 0.71073
    @test sfrm.lambdaKα1 == 0.7093
    @test sfrm.lambdaKα2 == 0.71359
    @test sfrm.lambdaKβ == 0.63229
    @test sfrm.xcenter == 386.9569
    @test sfrm.ycenter == 503.3636
end

@testset "setproperty" begin
    fname = "mo_LaB6_2_m8_m3_friedel_129f_MP96p95_03_0001.sfrm"
    sfrm = SFRM.load(joinpath(frames_folder, fname))
    @test_nowarn sfrm.type = "SCAN FRAME, ATTNUATED"
    @test_nowarn sfrm.filename = "test.sfrm"
    @test_nowarn sfrm.created = now()
    @test_nowarn sfrm.time = 0
    @test_nowarn sfrm.angles .= [1, 2, 3, 4]
    @test_nowarn sfrm.axis = 1
    @test_nowarn sfrm.increment = 2.0
    @test_nowarn sfrm.target = "Ag"
    @test_nowarn sfrm.voltage = 10.0
    @test_nowarn sfrm.current = 5.402252
    @test_nowarn sfrm.distance = 3.85683
    @test_nowarn sfrm.tth = 1
    @test_nowarn sfrm.omega = 2
    @test_nowarn sfrm.phi = 3
    @test_nowarn sfrm.chi = 4
    @test_nowarn sfrm.pix512percm = 1
    @test_nowarn sfrm.lambdaKα = 2
    @test_nowarn sfrm.lambdaKα1 = 3
    @test_nowarn sfrm.lambdaKα2 = 4
    @test_nowarn sfrm.lambdaKβ = 5
    @test_nowarn sfrm.xcenter = 0
    @test_nowarn sfrm.ycenter = 0
end

@testset "empty header" begin
    img = OffsetArrays.Origin(0)(rand(Int32, 2048, 1024))
    img[img .< typemin(Int8)] .= 0
    sfrm = SiemensFrame(img, Dict())
    path = joinpath(tempdir(), "empty_header.sfrm")
    @test_nowarn SFRM.save(path, sfrm)
    sfrm = SFRM.load(path)
    @test all(sfrm.image .== img)
end

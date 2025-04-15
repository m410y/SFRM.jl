using Test
using SFRM

include("Aqua.jl")

@testset "loading testframes" begin
    for file in readdir("./testframes", join = true)
        @test_nowarn SFRM.load(file)
    end
end

@testset "saving testframes" begin
    dir = tempdir()
    for file in readdir("./testframes", join = true)
        sfrm = SFRM.load(file)
        @test_nowarn SFRM.save(joinpath(dir, sfrm.filename), sfrm)
    end
end

@testset "Regions" begin
  @testset "Rectangle" begin
    r = RectangleRegion((1.,1.), (2.,3.))
    @test GeoStatsBase.center(r) == [3/2, 4/2]
    @test lowerleft(r) == [1., 1.]
    @test upperright(r) == [2., 3.]
    @test sides(r) == [1., 2.]
    @test GeoStatsBase.diagonal(r) == sqrt(1^2 + 2^2)
    @test volume(r) == 1*2
  end
end

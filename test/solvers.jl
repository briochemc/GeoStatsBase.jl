@testset "Solvers" begin
  @testset "CookieCutter" begin
    problem = SimulationProblem(RegularGrid{Float64}(100,100), (:facies => Int, :property => Float64), 3)
    solver = CookieCutter(DummySimSolver(:facies => NamedTuple()),
                          [0 => DummySimSolver(), 1 => DummySimSolver()])

    @test sprint(show, solver) == "CookieCutter"
    @test sprint(show, MIME"text/plain"(), solver) == "CookieCutter\n  └─facies ⇨ DummySimSolver\n    └─0 ⇨ DummySimSolver\n    └─1 ⇨ DummySimSolver\n"

    Random.seed!(1234)
    solution = solve(problem, solver)

    if visualtests
      gr(size=(800,600))
      @plottest plot(solution) joinpath(datadir,"CookieCutter.png") !istravis
    end
  end

  @testset "SeqSim" begin
    sdomain = RegularGrid{Float64}(100, 100)
    problem = SimulationProblem(sdomain, :var => Float64, 3)
    solver = SeqSim(:var => (estimator=DummyEstimator(),
                             neighborhood=BallNeighborhood{2}(10.),
                             minneighbors=1, maxneighbors=10,
                             marginal=Normal(), path=LinearPath()))

    Random.seed!(1234)
    solution = solve(problem, solver)

    if visualtests
      gr(size=(900,300))
      @plottest plot(solution) joinpath(datadir,"SeqSim.png") !istravis
    end
  end
end

using Aqua
using Documenter
using NoahYixiaoHashCode
using JuliaFormatter
using Test

DocMeta.setdocmeta!(
    NoahYixiaoHashCode,
    :DocTestSetup,
    :(using NoahYixiaoHashCode);
    recursive = true,
)

@testset verbose = true "NoahYixiaoHashCode.jl" begin
    @testset verbose = true "Code quality (Aqua.jl)" begin
        Aqua.test_all(NoahYixiaoHashCode; ambiguities = false)
    end

    @testset verbose = true "Code formatting (JuliaFormatter.jl)" begin
        @test format(NoahYixiaoHashCode; verbose = true, overwrite = false)
    end

    @testset verbose = true "Doctests (Documenter.jl)" begin
        doctest(NoahYixiaoHashCode)
    end

    @testset "Load file" begin
        problem = load_problem()
        @test problem.n_junctions == 11348
        @test problem.n_streets == 17958
        @test problem.n_cars == 8
        @test problem.total_time == 54000
        @test problem.init_j == 4517
        @test length(problem.junctions) == problem.n_junctions
        @test length(problem.streets) == problem.n_streets
        @test size(problem.sid_matrix) == (problem.n_junctions, problem.n_junctions)
        @test sum(NoahYixiaoHashCode.distance, problem.streets) == 1967444
    end

    @testset "Outneighbors" begin
        problem = load_problem()
        n₁ = NoahYixiaoHashCode.outneighbors(4517, problem)
        n₂ = [9806, 7281, 4122, 1032] .+ 1
        @test sort(n₁) == sort(n₂)
    end

    @testset "Empty solution" begin
        problem = load_problem()
        s = NoahYixiaoHashCode.empty_solution(problem)
        @test NoahYixiaoHashCode.is_feasible(s)
        @test NoahYixiaoHashCode.total_distance(s) == 0
    end

    @testset "Random Walk" begin
        problem = load_problem()
        s = NoahYixiaoHashCode.solve_randwalk(problem)
        @test NoahYixiaoHashCode.is_feasible(s)
        @test NoahYixiaoHashCode.total_distance(s) > 1
    end

    @testset "Greedy" begin
        problem = load_problem()
        s = NoahYixiaoHashCode.solve_greedy(problem)
        @test NoahYixiaoHashCode.is_feasible(s)
        @test NoahYixiaoHashCode.total_distance(s) > 1
    end

end

struct Junction{N<:Real}
    lat::N
    lon::N
end

struct Street{L<:Integer,T<:Integer}
    length::L
    time::T
end

struct RoutingProblem{J,S,M}
    n_junctions::Int
    n_cars::Int
    total_time::Int
    init_j::Int
    junctions::Vector{J}
    streets::Vector{S}
    sid_matrix::M
end

function RoutingProblem(problem_input)
    lines = eachline(problem_input)
    n_junctions, n_streets, total_time, n_cars, init_j = map(
        s -> parse(Int, s), split(iterate(lines)[1])
    )

    junctions = Vector{Junction}(undef, n_junctions)
    streets = Vector{Street}(undef, n_streets)
    v₁s = Int[]
    v₂s = Int[]
    sids = Int[]

    for i in 1:n_junctions
        lat, lon = map(
            s -> parse(Float64, s), split(iterate(lines)[1])
        )
        junctions[i] = Junction(lat, lon)
    end

    for i in 1:n_streets
        v₁, v₂, d, t, l = map(
            s -> parse(Int, s), split(iterate(lines)[1])
        )
        v₁ += 1  # Julia uses 1-based indexing.
        v₂ += 1
        streets[i] = Street(l, t)
        push!(v₁s, v₁)
        push!(v₂s, v₂)
        push!(sids, i)
        if d == 2
            push!(v₂s, v₁)
            push!(v₁s, v₂)
            push!(sids, i)
        end
    end

    if !isempty(lines)
        @error "$(problem_input) contains extra lines."
    end

    sid_matrix = SparseArrays.sparse(v₁s, v₂s, sids)
    return RoutingProblem(
        n_junctions, n_cars, total_time, init_j, junctions, streets, sid_matrix
    )
end

function RoutingProblem()
    paris_file = normpath(joinpath(@__DIR__, "..", "data", "paris_54000.txt"))
    return RoutingProblem(paris_file)
end

struct Solution
    routes::Vector{Vector{Int}}
end

function save_text(problem::RoutingProblem, solution::Solution; io=stdout)
    println(io, problem.n_cars)
    for i in 1:problem.n_cars
        route = solution.routes[i]
        println(io, length(route))
        for junction in route
            println(io, junction - 1)  # Julia uses 1-based indexing.
        end
    end
end

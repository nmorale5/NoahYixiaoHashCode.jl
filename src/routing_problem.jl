"""
    RoutingProblem

Store the information of a routing problem.

# Fields
- `n_junctions::Int`: number of junctions
- `n_cars::Int`: number of cars
- `n_streets::Int`: number of streets
- `total_time::Int`: time limit
- `init_j::Int`: id of the initial junction
- `junctions::J`: list of all the [`Junction`](@ref)s
- `streets::S`: list of all the [`Street`](@ref)s
- `sid_matrix::M`: a table that shows the indices of streets. It should be a
    `SparseArrays.SparseMatrixCSC`, and `sid_matrix[j_end, j_begin]` is the
    index of the street if it exists otherwise 0.
"""
Base.@kwdef struct RoutingProblem{J,S,M}
    n_junctions::Int
    n_cars::Int
    n_streets::Int
    total_time::Int
    init_j::Int
    junctions::J
    streets::S
    sid_matrix::M
end

function outneighbors(i, p::RoutingProblem)
    rows = rowvals(p.sid_matrix)
    return view(rows, nzrange(p.sid_matrix, i))
end

@inline function street_id(j_begin, j_end, p::RoutingProblem)
    return p.sid_matrix[j_end, j_begin]
end

@inline function street(j_begin, j_end, p::RoutingProblem)
    return p.streets[street_id(j_begin, j_end, p)]
end

@inline function has_street(j_begin, j_end, p::RoutingProblem)
    return p.sid_matrix[j_end, j_begin] != 0
end

"""
    load_problem(problem_input=normpath(joinpath(@__DIR__, "..", "data", "paris_54000.txt")))

Return a [`RoutingProblem`](@ref) defined by the input file.
"""
function load_problem(
    problem_input = normpath(joinpath(@__DIR__, "..", "data", "paris_54000.txt")),
)
    lines = eachline(problem_input)
    n_junctions, n_streets, total_time, n_cars, init_j =
        map(s -> parse(Int, s), split(iterate(lines)[1]))
    init_j += 1

    junctions = Vector{Junction{Float64}}(undef, n_junctions)
    streets = Vector{Street{Int,Int}}(undef, n_streets)
    v₁s = Int[]
    v₂s = Int[]
    sids = Int[]

    for i = 1:n_junctions
        lat, lon = map(s -> parse(Float64, s), split(iterate(lines)[1]))
        junctions[i] = Junction(lat, lon)
    end

    for i = 1:n_streets
        v₁, v₂, d, t, l = map(s -> parse(Int, s), split(iterate(lines)[1]))
        v₁ += 1  # Julia uses 1-based indexing.
        v₂ += 1
        streets[i] = Street(l, t)

        push!(v₂s, v₁)
        push!(v₁s, v₂)
        push!(sids, i)

        if d == 2
            push!(v₁s, v₁)
            push!(v₂s, v₂)
            push!(sids, i)
        end
    end

    if !isempty(lines)
        @error "$(problem_input) contains extra lines."
    end

    sid_matrix = sparse(v₁s, v₂s, sids)
    return RoutingProblem(;
        n_junctions = n_junctions,
        n_cars = n_cars,
        n_streets = n_streets,
        total_time = total_time,
        init_j = init_j,
        junctions = junctions,
        streets = streets,
        sid_matrix = sid_matrix,
    )
end

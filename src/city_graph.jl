struct Junction{N<:Real}
    lat::N
    lon::N
end

struct Street{L<:Integer,T<:Integer}
    distance::L
    time_cost::T
end

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

@inline function time_cost(s::Street)
    return s.time_cost
end

@inline function distance(s::Street)
    return s.distance
end

@inline function time_cost(j_begin, j_end, p::RoutingProblem)
    return time_cost(street(j_begin, j_end, p))
end

@inline function distance(j_begin, j_end, p::RoutingProblem)
    return distance(street(j_begin, j_end, p))
end

function load_problem(problem_input)
    lines = eachline(problem_input)
    n_junctions, n_streets, total_time, n_cars, init_j = map(
        s -> parse(Int, s), split(iterate(lines)[1])
    )
    init_j += 1

    junctions = Vector{Junction{Float64}}(undef, n_junctions)
    streets = Vector{Street{Int, Int}}(undef, n_streets)
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
        n_junctions=n_junctions,
        n_cars=n_cars,
        n_streets=n_streets,
        total_time=total_time,
        init_j=init_j,
        junctions=junctions,
        streets=streets,
        sid_matrix=sid_matrix
    )
end

function load_problem()
    paris_file = normpath(joinpath(@__DIR__, "..", "data", "paris_54000.txt"))
    return load_problem(paris_file)
end

struct Solution{R}
    problem::RoutingProblem
    routes::R
end

function route(car_id, s::Solution)
    return s.routes[car_id]
end

function empty_solution(p::RoutingProblem)
    s = Solution(p, collect([p.init_j] for _ in 1:p.n_cars))
    return s
end

function save_text(solution::Solution; io=stdout)
    problem = solution.problem
    println(io, problem.n_cars)
    for i in 1:solution.problem.n_cars
        route = solution.routes[i]
        println(io, length(route))
        for junction in route
            println(io, junction - 1)  # Julia uses 1-based indexing.
        end
    end
end

function solve_randwalk(problem::RoutingProblem)
    solution = empty_solution(problem)
    t_free_cars = fill(0, problem.n_cars)

    for t in 0:problem.total_time
        for car in 1:problem.n_cars
            if t >= t_free_cars[car]
                junc_begin = route(car, solution)[end]
                junc_end = rand(outneighbors(junc_begin, problem))
                tᵣ = time_cost(junc_begin, junc_end, problem)
                t_free = t + tᵣ
                if t_free <= problem.total_time
                    t_free_cars[car] = t_free
                    push!(route(car, solution), junc_end)
                end
            end
        end
    end
    return solution
end

function is_feasible(solution::Solution)
    problem = solution.problem
    for car in problem.n_cars
        juncs = route(car, solution)
        total_time_cost = 0
        for i in 1:(length(juncs) - 1)
            junc_begin = juncs[i]
            junc_end = juncs[i+1]
            if !has_street(junc_begin, junc_end, problem)
                return false
            end
            total_time_cost += time_cost(junc_begin, junc_end, problem)
        end
        if total_time_cost > problem.total_time
            return false
        end
    end
    return true
end

function total_distance(solution::Solution; check=true)
    if check
        if !is_feasible(solution)
            @error "This solution is not feasible."
        end
    end

    problem = solution.problem
    visited = fill(false, problem.n_streets)
    total_distance = 0

    for car in problem.n_cars
        juncs = route(car, solution)
        for i in 1:(length(juncs) - 1)
            junc_begin = juncs[i]
            junc_end = juncs[i+1]
            sid = street_id(junc_begin, junc_end, problem)
            if !visited[sid]
                total_distance += distance(problem.streets[sid])
            end
            visited[sid] = true
        end
    end

    return total_distance
end

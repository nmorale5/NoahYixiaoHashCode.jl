"""
    max_heuristic_junction(
        j₀,
        nvisited::Vector{<:Integer},
        problem::RoutingProblem,
        search_depth::Integer,
    )

Return the maximum heuristic and the corresponding next node.

# Arguments
- `j₀`: the starting node
- `nvisited`: a vector for how many times each street has been traversed before
- `problem`: the [`RoutingProblem`](@ref) to solve
- `search_depth`: the number of steps for the look-ahead
"""

function max_heuristic_junction(
    j₀,
    nvisited::Vector{<:Integer},
    problem::RoutingProblem,
    search_depth::Integer,
)
    if search_depth <= 0
        return 0, 0
    else
        h_max = -typemin(eltype(nvisited))
        j₁_max = 0
        for j₁ in outneighbors(j₀, problem)
            sid = street_id(j₀, j₁, problem)
            street = problem.streets[sid]

            v₀ = nvisited[sid]
            nvisited[sid] += 1
            h₁, _ = max_heuristic_junction(j₁, nvisited, problem, search_depth - 1)
            nvisited[sid] = v₀

            h₀₁ = nvisited[sid] == 0 ? distance(street) : -nvisited[sid] * time_cost(street)
            h₀ = h₀₁ + h₁

            if h₀ > h_max
                h_max = h₀
                j₁_max = j₁
            end
        end
        return h_max, j₁_max
    end
end

"""
    solve_greedy(problem::RoutingProblem; search_depth = 10)

Solve a [`RoutingProblem`](@ref) using a greedy algorithm.

# Arguments
- `problem`: the `RoutingProblem` to solve
- `search_depth`: the number of steps for the look-ahead. When it is 1,
    the code uses a greedy algorithm without a look-ahead.
"""
function solve_greedy(problem::RoutingProblem; search_depth = 10)
    solution = empty_solution(problem)
    nvisited = fill(0, problem.n_streets)

    for car = 1:problem.n_cars
        t = 0
        while true
            junc_begin = route(car, solution)[end]
            _, junc_end =
                max_heuristic_junction(junc_begin, nvisited, problem, search_depth)

            t += time_cost(street(junc_begin, junc_end, problem))
            if t <= problem.total_time
                push!(route(car, solution), junc_end)
                nvisited[street_id(junc_begin, junc_end, problem)] += 1
            else
                break
            end
        end
    end

    return solution
end

function max_heuristic_junction(
    j₀,
    nvisited::Vector{<:Integer},
    problem::RoutingProblem,
    search_depth,
)
    if search_depth == 0
        return (0, 0, 0), 0
    else
        h_max = (-typemin(eltype(nvisited)), 0, 0)
        j₁_max = 0
        for j₁ in outneighbors(j₀, problem)
            sid = street_id(j₀, j₁, problem)
            street = problem.streets[sid]

            v₀ = nvisited[sid]
            nvisited[sid] += 1
            h₁, _ = max_heuristic_junction(j₁, nvisited, problem, search_depth - 1)
            nvisited[sid] = v₀

            a, b, c = h₁
            h₀ = (a - nvisited[sid], b + distance(street), c - time_cost(street))

            if h₀ > h_max
                h_max = h₀
                j₁_max = j₁
            end
        end
        return h_max, j₁_max
    end
end

"""
    solve_greedy(problem::RoutingProblem)

Solve a `RoutingProblem` using a greedy algorithm.
"""
function solve_greedy(problem::RoutingProblem; search_depth = 10)
    solution = empty_solution(problem)
    t_free_cars = fill(0, problem.n_cars)
    nvisited = fill(0, problem.n_streets)

    for car = 1:problem.n_cars
        for t = 0:problem.total_time
            if t >= t_free_cars[car]
                junc_begin = route(car, solution)[end]
                _, junc_end =
                    max_heuristic_junction(junc_begin, nvisited, problem, search_depth)

                tᵣ = time_cost(street(junc_begin, junc_end, problem))
                t_free = t + tᵣ
                if t_free <= problem.total_time
                    t_free_cars[car] = t_free
                    push!(route(car, solution), junc_end)
                    nvisited[street_id(junc_begin, junc_end, problem)] += 1
                end
            end
        end
    end
    return solution
end

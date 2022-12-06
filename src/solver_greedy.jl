@inline function max_heuristic_junction(
    j₀,
    nvisited::Vector{<:Integer},
    problem::RoutingProblem,
    ::Val{search_depth},
) where {search_depth}
    if search_depth == 0
        return 0, 0
    else
        h_max = -typemin(eltype(nvisited))
        j₁_max = 0
        for j₁ in outneighbors(j₀, problem)
            sid = street_id(j₀, j₁, problem)
            street = problem.streets[sid]

            v₀ = nvisited[sid]
            nvisited[sid] += 1
            h₁, _ = max_heuristic_junction(j₁, nvisited, problem, Val(search_depth - 1))
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
    solve_greedy(problem::RoutingProblem)

Solve a `RoutingProblem` using a greedy algorithm.
"""
function solve_greedy(problem::RoutingProblem; search_depth = 10)
    solution = empty_solution(problem)
    nvisited = fill(0, problem.n_streets)

    for car = 1:problem.n_cars
        t_free = 0
        for t = 0:problem.total_time
            if t >= t_free
                junc_begin = route(car, solution)[end]
                _, junc_end =
                    max_heuristic_junction(junc_begin, nvisited, problem, Val(search_depth))

                tᵣ = time_cost(street(junc_begin, junc_end, problem))
                t_free_next = t + tᵣ
                if t_free_next <= problem.total_time
                    t_free = t_free_next
                    push!(route(car, solution), junc_end)
                    nvisited[street_id(junc_begin, junc_end, problem)] += 1
                end
            end
        end
    end

    return solution
end

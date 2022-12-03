@inline function heuristic_greedy(j₀, j₁, nvisited::Vector{<:Integer}, problem::RoutingProblem, ::Val{search_depth}) where search_depth
    sid = street_id(j₀, j₁, problem)
    street = problem.streets[sid]
    if search_depth == 0
        a, b, c = (0, 0, 0)
    else
        v₀ = nvisited[sid]
        nvisited[sid] += 1
        h_max = (-problem.n_streets, 0, 0)
        for j in outneighbors(j₁, problem)
            h₁ = heuristic_greedy(j₁, j, nvisited, problem, Val(search_depth-1))
            if h₁ > h_max
                h_max = h₁
            end
        end
        a, b, c = h_max
        nvisited[sid] = v₀
    end
    return (a-nvisited[sid], b+distance(street), c-time_cost(street))
end

"""
    solve_greedy(problem::RoutingProblem)

Solve a `RoutingProblem` using a greedy algorithm.
"""
function solve_greedy(problem::RoutingProblem)
    solution = empty_solution(problem)
    t_free_cars = fill(0, problem.n_cars)
    nvisited = fill(0, problem.n_streets)

    for car = 1:problem.n_cars
        for t in 0:problem.total_time
            if t >= t_free_cars[car]
                junc_begin = route(car, solution)[end]
                junc_end = argmax(
                    j -> heuristic_greedy(junc_begin, j, nvisited, problem, Val(9)),
                    outneighbors(junc_begin, problem),
                )

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
    println(total_distance(solution))
    return solution
end

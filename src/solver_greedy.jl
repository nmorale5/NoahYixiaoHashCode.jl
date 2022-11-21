function heuristic_greedy(
        j₀, j₁, visited::Vector{Bool}, problem::RoutingProblem
    )
    sid = street_id(j₀, j₁, problem)
    street = problem.streets[sid]
    eff =  distance(street) / time_cost(street)
    if visited[sid]
        return -rand(typeof(eff))
    else
        return eff
    end
end

function solve_greedy(problem::RoutingProblem)
    solution = empty_solution(problem)
    t_free_cars = fill(0, problem.n_cars)
    visited = fill(false, problem.n_streets)

    for t in 0:problem.total_time
        for car in 1:problem.n_cars
            if t >= t_free_cars[car]
                junc_begin = route(car, solution)[end]
                junc_end = argmax(
                    j -> heuristic_greedy(junc_begin, j, visited, problem),
                    outneighbors(junc_begin, problem)
                )

                tᵣ = time_cost(street(junc_begin, junc_end, problem))
                t_free = t + tᵣ
                if t_free <= problem.total_time
                    t_free_cars[car] = t_free
                    push!(route(car, solution), junc_end)
                    visited[street_id(junc_begin, junc_end, problem)] = true
                end
            end
        end
    end
    return solution
end

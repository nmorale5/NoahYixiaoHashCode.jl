"""
    solve_randwalk(problem::RoutingProblem)

Solve a `RoutingProblem` using random walk.
"""
function solve_randwalk(problem::RoutingProblem)
    solution = empty_solution(problem)
    t_free_cars = fill(0, problem.n_cars)

    for t = 0:problem.total_time
        for car = 1:problem.n_cars
            if t >= t_free_cars[car]
                junc_begin = route(car, solution)[end]
                junc_end = rand(outneighbors(junc_begin, problem))
                tᵣ = time_cost(street(junc_begin, junc_end, problem))
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

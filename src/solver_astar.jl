function make_astar_heuristic(problem::RoutingProblem, visiteds::Vector{Int}, weight::Float64)
    # choose a random point on the map, get distance to it, and add to 
    goal = rand(problem.junctions)
    dist(j₀::Junction, j₁::Junction) = sqrt((j₀.lat - j₁.lat)^2 + (j₀.lon - j₁.lon)^2)
    diff(j₀::Junction, j₁::Junction) = dist(j₁, goal) - dist(j₀, goal)
    vis_count(id₀::Int64, id₁::Int64) = visiteds[street_id(id₀, id₁, problem)]
    function heuristic(id₀::Int64, id₁::Int64)
        j₀ = problem.junctions[id₀]
        j₁ = problem.junctions[id₁]
        return weight * diff(j₀, j₁) + vis_count(id₀, id₁)
    end
    return heuristic
end


function one_trial_astar(problem::RoutingProblem, heuristic_weight::Float64=10.)
    solution = empty_solution(problem)
    t_free_cars = fill(0, problem.n_cars)
    nvisited = fill(0, problem.n_streets)
    coverage = 0

    heuristics = [make_astar_heuristic(problem, nvisited, heuristic_weight) for _ in 1:problem.n_cars]

    for t = 0:problem.total_time
        for car = 1:problem.n_cars
            if t < t_free_cars[car] continue end

            junc_begin = route(car, solution)[end]
            junc_end = argmin(
                j -> heuristics[car](junc_begin, j),
                outneighbors(junc_begin, problem),
            )

            tᵣ = time_cost(street(junc_begin, junc_end, problem))
            t_free = t + tᵣ
            if t_free <= problem.total_time
                t_free_cars[car] = t_free
                push!(route(car, solution), junc_end)
                sid = street_id(junc_begin, junc_end, problem)
                if nvisited[sid] == 0
                    coverage += distance(problem.streets[sid])
                end
                nvisited[sid] += 1
            end
        end
    end
    return (solution, coverage)
end

"""
    solve_astar(problem::RoutingProblem)

Solve a `RoutingProblem` by simulating A* heuristic algorithms,
each with a random weight for distance in the heuristic formula
"""
function solve_astar(problem::RoutingProblem, trials=10000)
    return argmax(
        out -> out[2],
        [one_trial_astar(problem) for _ in 1:trials]
    )[1]
end

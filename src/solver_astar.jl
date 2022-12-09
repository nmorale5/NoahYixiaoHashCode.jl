function astar_heuristic_class(problem::RoutingProblem, goals::Vector{Junction{Float64}}, nvisited::Vector{Int64})
    # something similar to a python class
    weights = [0., 0., 0.]
    function randomize_weights!()
        # attempt to normalize based on calculations in averages.jl
        weights[1] = rand() * 2.0
        weights[2] = rand() * 10.0
        weights[3] = rand() * 0.01
    end
    vis_count(id₀::Int64, id₁::Int64) = nvisited[street_id(id₀, id₁, problem)]
    dist(j₀::Junction, j₁::Junction) = sqrt((j₀.lat - j₁.lat)^2 + (j₀.lon - j₁.lon)^2)
    diff(j₀::Junction, j₁::Junction, goal::Junction) = dist(j₁, goal) - dist(j₀, goal)
    function efficiency(id₀::Int64, id₁::Int64)
        street = problem.streets[street_id(id₀, id₁, problem)]
        return -distance(street) / time_cost(street)  # negative since we're finding a minimum
    end
    function heuristic(id₀::Int64, id₁::Int64, car::Int64)
        j₀ = problem.junctions[id₀]
        j₁ = problem.junctions[id₁]
        return weights[1] * vis_count(id₀, id₁) + weights[2] * diff(j₀, j₁, goals[car]) + weights[3] * efficiency(id₀, id₁)
    end
    return heuristic, randomize_weights!, weights
end


function one_trial_astar(problem::RoutingProblem, nvisited::Vector{Int}, heuristic)
    solution = empty_solution(problem)
    t_free_cars = fill(0, problem.n_cars)
    # nvisited = fill(0, problem.n_streets)
    coverage = 0

    for t = 0:problem.total_time
        for car = 1:problem.n_cars
            if t < t_free_cars[car] continue end

            junc_begin = route(car, solution)[end]
            junc_end = argmin(
                j -> heuristic(junc_begin, j, car),
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
    return solution, coverage
end

"""
    solve_astar(problem::RoutingProblem)

Solve a `RoutingProblem` by simulating A* heuristic algorithms,
each with a random weight for distance in the heuristic formula
"""
function solve_astar(problem::RoutingProblem, trials=10000)
    goals = best_goals
    nvisited = fill(0, problem.n_streets)
    heuristic, randomize_weights!, weights = astar_heuristic_class(problem, goals, nvisited)
    best_coverage = 0
    best_solution = nothing
    best_weights = nothing
    # best_goals = nothing
    for _ in 1:trials
        # new_goals = get_optimal_points(problem)
        # for i in 1:8
        #     goals[i] = new_goals[i]
        # end
        fill!(nvisited, 0)
        randomize_weights!()
        solution, coverage = one_trial_astar(problem, nvisited, heuristic)
        if coverage > best_coverage
            best_coverage = coverage
            best_solution = solution
            best_weights = copy(weights)
            # best_goals = copy(goals)
            println(weights, coverage)
            # println(goals)
        end
    end
    println("done")
    # println(best_goals)
    return best_solution
end

function test_astar(problem::RoutingProblem, w)
    goals = preloaded_goals
    nvisited = fill(0, problem.n_streets)
    heuristic, randomize_weights!, weights = astar_heuristic_class(problem, goals, nvisited)
    weights[1] = w[1]
    weights[2] = w[2]
    weights[3] = w[3]
    solution, coverage = one_trial_astar(problem, nvisited, heuristic)
    println(coverage, weights)
    return solution
end
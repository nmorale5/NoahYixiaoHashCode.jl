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

function is_feasible(solution::Solution)
    problem = solution.problem
    for car in problem.n_cars
        juncs = route(car, solution)
        total_time_cost = 0
        for i in 1:(length(juncs) - 1)
            junc_begin = juncs[i]
            junc_end = juncs[i + 1]
            if !has_street(junc_begin, junc_end, problem)
                return false
            end
            total_time_cost += time_cost(street(junc_begin, junc_end, problem))
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
            junc_end = juncs[i + 1]
            sid = street_id(junc_begin, junc_end, problem)
            if !visited[sid]
                total_distance += distance(problem.streets[sid])
            end
            visited[sid] = true
        end
    end

    return total_distance
end

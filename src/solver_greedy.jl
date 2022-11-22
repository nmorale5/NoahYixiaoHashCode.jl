struct IntRealPair{I<:Integer, R<:Real} <: Number
    n::I
    f::R
end

function Base.isless(a::IntRealPair, b::IntRealPair)
   return a.n < b.n || (a.n == b.n && a.f < b.f)
end

function heuristic_greedy(
        j₀, j₁, visited::Vector{Int}, problem::RoutingProblem
    )
    sid = street_id(j₀, j₁, problem)
    street = problem.streets[sid]
    eff =  distance(street) / time_cost(street)
    if visited[sid] > 0
        return IntRealPair(-visited[sid], rand(typeof(eff)))
    else
        return IntRealPair(0, eff)
    end
end

function solve_greedy(problem::RoutingProblem)
    solution = empty_solution(problem)
    t_free_cars = fill(0, problem.n_cars)
    nvisited = fill(0, problem.n_streets)

    for t in 0:problem.total_time
        for car in 1:problem.n_cars
            if t >= t_free_cars[car]
                junc_begin = route(car, solution)[end]
                junc_end = argmax(
                    j -> heuristic_greedy(junc_begin, j, nvisited, problem),
                    outneighbors(junc_begin, problem)
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
    return solution
end

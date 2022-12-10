# compare the "efficiency" or "velocity" of two streets
# by dividing distance by time cost (and cross-multiplying)
function velocity_isless(s₁::Street, s₂::Street)
    return distance(s₁) * time_cost(s₂) < distance(s₂) * time_cost(s₁)
end

"""
    total_distance_upper_bound(problem::RoutingProblem)

Compute an upper bound on the given RoutingProblem following the
algorithm descibed in `upper_bound_doc.md`
"""
function total_distance_upper_bound(problem::RoutingProblem)
    streets = problem.streets
    streets_by_velocity = sort(streets; lt = velocity_isless, rev = true)
    t = 0
    d = 0
    # repeatedly take the next-most-efficient street
    # until total time is met or exceeded
    for street in streets_by_velocity
        if t >= problem.n_cars * problem.total_time
            break
        end
        d += distance(street)
        t += time_cost(street)
    end
    return d
end

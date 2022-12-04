function average_distance(problem::RoutingProblem)
    total = 0
    for street in problem.streets
        junc1 = problem.junctions[street.j₀]
        junc2 = problem.junctions[street.j₁]
        total += √((junc1.lat - junc2.lat)^2 + (junc1.lon - junc2.lon)^2)
    end
    return total / problem.n_streets
    # 0.000969957924390458
end

function average_efficiency(problem::RoutingProblem)
    total = 0
    for street in problem.streets
        total += distance(street) / time_cost(street)
    end
    return total / problem.n_streets
    # 10.155550354534322
end
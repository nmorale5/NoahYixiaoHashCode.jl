function get_optimal_points(problem::RoutingProblem)
    # construct a matrix to be used as an argument in kmeans algorithm
    points = zeros(2, problem.n_junctions)
    for j in 1:problem.n_junctions
        points[1, j] = problem.junctions[j].lat
        points[2, j] = problem.junctions[j].lon
    end
    # run algorithm
    centers = kmeans(points, 8).centers
    # reconstruct back into a Vector of Junctions
    return [Junction(centers[1, car], centers[2, car]) for car in 1:8]
end
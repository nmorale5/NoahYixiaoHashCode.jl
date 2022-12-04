# includes each junction only once (somehow better)
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

# includes each junction as many times as it has streets, 
# effectively weighing more frequent junctions more heavily (somehow worse)
# function get_optimal_points(problem::RoutingProblem)
#     # construct a matrix to be used as an argument in kmeans algorithm
#     points = zeros(2, 2*problem.n_streets)
#     for s in 1:problem.n_streets
#         street = problem.streets[s]
#         points[1, 2s-1] = problem.junctions[street.j₀].lat
#         points[2, 2s-1] = problem.junctions[street.j₀].lon
#         points[1, 2s] = problem.junctions[street.j₁].lat
#         points[2, 2s] = problem.junctions[street.j₁].lon
#     end
#     # run algorithm
#     centers = kmeans(points, 8).centers
#     # reconstruct back into a Vector of Junctions
#     return [Junction(centers[1, car], centers[2, car]) for car in 1:8]
# end
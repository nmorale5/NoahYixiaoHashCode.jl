```@meta
CurrentModule = NoahYixiaoHashCode
```

# NoahYixiaoHashCode

Documentation for [NoahYixiaoHashCode](https://github.com/nmorale5/NoahYixiaoHashCode.jl).

## Usage

```julia
using NoahYixiaoHashCode

problem = load_problem()
solution = solve_greedy(problem)
open("solution_NoahYixiaoHashCode.txt", "w") do f
    save_text(solution; io=f)
end
```

## Optimization Algorithm

### Problem and Notations

Suppose we have a city represented by a graph, $G = (\{n\}, \{s\})$.
Here, $\{n\} = \{n_i \;\mathrm{where}\; i = 1, 2, \dots, N_n\}$ is a collection of the nodes;
$\{s\} = \{s_n \;\mathrm{where}\; n = 1, 2, \dots, N_s\}$ is a collection of the streets.
$N_n$ and $N_s$ are the numbers of the nodes and streets respectively.
Each street, $s_n$, can be viewed as a tuple, $(x_n, y_n, d_n, t_n, l_n)$. Here,
$x_n$ and $y_n$ are the two nodes $s_n$ connect;
$d_n$ is whether this street is one-way;
$t_n$ is the time cost of traversing $s_n$;
$l_n$ is the length of $s_n$.

In this problem, we have multiple cars, the number of which is referred to as $N_c$,
They start from the same initial node. The goal is to maximize the total distance
of the the streets that all the cars traverse within a limited time.


### Greedy algorithm

Our algorithm is a greedy algorithm.
In order to avoid traversing certain streets repeatedly, we store how many
times each street has been traversed, which will be referred to as
$T_n$ where $s_n$ is the $n$-th street.
At each step, we maximize the heuristic below among all the streets that
the car can traverse the next step.

$h(s_n)
= \left\{\begin{array}{lr}l_n, &  T_n = 0 \\
-t_n\times T_n, & T_n > 0 \\
\end{array}\right.$

If not all the streets have been traversed before, this algorithm maximizes
the distance of the next street.
If all the streets have been traversed before, this algorithm tries to
avoid traversing certain streets over and over again.
Actually, $h$ can be any function of $l_n$, $t_n$, and $T_n$.
The equation above is just one example that we found easy to calculate
and performs well.

Note that $T_n$ is updated at every step. If we decide to traverse $s_n$,
we need to do $T_n = T_n + 1$ soon after that. $T_n$ can be larger than $1$.

### Look-ahead

We use a look ahead to improve the greedy algorithm. We sum over the values
of the heuristic for a certain number of steps. This is done
with a tree search and the time complexity is
roughly $O(d^L)$, where $d$ is the average degree of nearby vertices
and $L$ is the number of steps to look ahead.
Note that the change in $T_n$ due to previous steps is considered in
the calculation.

### Multiple cars

We schedule the routes for all cars sequentially.
First, we use the above algorithm for the first car. After running out
of time of the first cat, we start to schedule the route of the second car.

However, $T_n$ is shared by all the cars. So, the later cars can also learn
from previous cars.

### Upper Bound Algorithm

To compute our upper bound, we relax one of the rules related to traveling.
Normally, at any timestep, cars on a graph $G$ can only travel along one of the
streets adjacent to the junction they're currently at.  Instead, we allow cars
to travel along any street at any timestep, meaning essentially every junction
is connected to every other junction with distance 0 and time cost 0 on a
larger graph $G'$.  By doing this, we skip the need for good routing since the
street taken no longer affects the possible streets to choose from in the next
step.

The maximum distance coverable in $G'$ must be at least as much as the maximum
distance coverable in $G$ (for the same total amount of time), since $G'$
contains all the edges of $G$ and then some.

To find an upper bound on the maximum distance coverable on $G'$, in at most
time $T$, we employ the following algorithm $A$:

1. Compute the "efficiency" of each street as its length divided by its time
   cost, and sort all streets in an array from greatest to least efficiency.

2. Set up running totals for total time and total distance covered,
   initializing both to 0.

3. While total time has not yet reached $T$, pop the next street from the front
   of the array (the street with the highest efficiency), and add its time and
   distance to the running totals.

4. Once the total time has met or exceeded $T$, return the total distance.

The total time cost of algorithm $A$ is at least $T$. Any algorithm $B$ that
tries to route the cars following the original rules must take at most time
$T$. This means in order for algorithm $B$ to cover a greater distance, it
would need an average efficiency greater than that of algorithm $A$. However,
algorithm $A$ already chooses the maximum possible efficiency, so algorithm $B$
cannot possibly be better.

In conclusion, the algorithm above is a valid upper bound on the maximum
possible distance under the original rules. Running the algorithm on the sample
Paris data with a maximum time of 18,000 yields an upper bound of 1,525,503.


## Index

```@index
```

```@autodocs
Modules = [NoahYixiaoHashCode]
```

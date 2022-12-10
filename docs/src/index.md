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

## Index

```@index
```

```@autodocs
Modules = [NoahYixiaoHashCode]
```

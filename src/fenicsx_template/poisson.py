"""Poisson problem on the unit square.

The exact solution is ``u = sin(π x) sin(π y)``, so ``-Δu = 2 π² u`` and
``u = 0`` on the boundary. Linear elements cannot represent it exactly, and
the L2 error should drop as the mesh is refined.
"""

from __future__ import annotations

import sys

from mpi4py import MPI
from petsc4py.PETSc import ScalarType

import numpy as np
import ufl
from dolfinx import fem, mesh
from dolfinx.fem.petsc import LinearProblem


def solve_poisson(n: int = 16) -> float:
    """Return the global L2 error of the Poisson solution on an ``n`` by ``n`` mesh."""
    if n < 1:
        message = "mesh size n must be positive"
        raise ValueError(message)

    domain = mesh.create_unit_square(MPI.COMM_WORLD, n, n, mesh.CellType.triangle)
    space = fem.functionspace(domain, ("Lagrange", 1))

    facet_dim = domain.topology.dim - 1
    boundary = mesh.locate_entities_boundary(
        domain,
        dim=facet_dim,
        marker=lambda x: np.ones(x.shape[1], dtype=bool),
    )
    dofs = fem.locate_dofs_topological(V=space, entity_dim=facet_dim, entities=boundary)
    boundary_condition = fem.dirichletbc(value=ScalarType(0), dofs=dofs, V=space)

    trial = ufl.TrialFunction(space)
    test = ufl.TestFunction(space)
    coordinates = ufl.SpatialCoordinate(domain)
    exact = ufl.sin(ufl.pi * coordinates[0]) * ufl.sin(ufl.pi * coordinates[1])
    source = 2 * ufl.pi**2 * exact
    stiffness = ufl.inner(ufl.grad(trial), ufl.grad(test)) * ufl.dx
    load = ufl.inner(source, test) * ufl.dx
    problem = LinearProblem(
        stiffness,
        load,
        bcs=[boundary_condition],
        petsc_options_prefix="poisson_",
        petsc_options={
            "ksp_type": "preonly",
            "pc_type": "lu",
            "ksp_error_if_not_converged": True,
        },
    )
    solution = problem.solve()

    error_form = fem.form(ufl.inner(solution - exact, solution - exact) * ufl.dx)
    local_error = fem.assemble_scalar(error_form)
    global_error = domain.comm.allreduce(local_error, op=MPI.SUM)
    return float(np.real(np.sqrt(global_error)))


def main() -> None:
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 16
    error = solve_poisson(n)
    if MPI.COMM_WORLD.rank == 0:
        print(f"L2 error (n={n}): {error:.6e}")


if __name__ == "__main__":
    main()

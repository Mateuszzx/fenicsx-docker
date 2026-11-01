"""FEniCSx project template."""

from importlib.metadata import version

from fenicsx_template.poisson import solve_poisson

__all__ = ["solve_poisson"]
__version__ = version("fenicsx-template")

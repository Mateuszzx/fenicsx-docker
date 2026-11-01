import pytest

from fenicsx_template import solve_poisson


def test_poisson_error_decreases_with_mesh_size() -> None:
    coarse = solve_poisson(8)
    fine = solve_poisson(16)
    assert fine < coarse
    assert fine < 5e-2


def test_poisson_rejects_non_positive_mesh() -> None:
    with pytest.raises(ValueError, match="positive"):
        solve_poisson(0)

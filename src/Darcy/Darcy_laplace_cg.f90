! Sam(oa)² - SFCs and Adaptive Meshes for Oceanic And Other Applications
! Copyright (C) 2010 Oliver Meister, Kaveh Rahnema
! This program is licensed under the GPL, for details see the file LICENSE


#include "Compilation_control.f90"

#if 0
    module darcy_pressure_solver_cg
        !this is a dummy module for automated dependency analysis
        use SFC_edge_traversal
        use Samoa_darcy
        use linear_solver
    end module
#endif

#if defined(_DARCY)
#   define _solver              darcy_pressure_solver_cg
#   define _solver_use          Samoa_darcy

#   define _gv_node_size        _DARCY_P_NODE_SIZE
#   define _gv_edge_size        _DARCY_P_EDGE_SIZE
#   define _gv_cell_size        _DARCY_P_CELL_SIZE

#   define _gm_A                darcy_gm_A
#   define _gv_x                darcy_gv_p

#   define _gv_r                darcy_gv_r
#   define _gv_d                darcy_gv_d
#   define _gv_u                darcy_gv_A_d
#   define _gv_trace_A          darcy_gv_mat_diagonal
#   define _gv_dirichlet        darcy_gv_is_dirichlet_boundary

#   include "../Solver/CG.f90"
#endif

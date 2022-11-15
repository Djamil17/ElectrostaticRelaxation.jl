#=
Script: main for the relxation simulation 
Author: Djamil Lakhdar-Hamina
Date: 11/10/2022
Description: 

=#

using lattice
using relax
using animate

function main(length,n_grids,intitial_potential, trials)

    lattice=make_lattice_node(length,n_grids,intitial_potential)
    animate(lattice,trials)

end 



#=
Script: 
Author: Djamil Lakhdar-Hamina
Date:
    Created: 
    Modified: 
Description: 
=#

using Images 

mutable struct Node 

    x_::Real
    y_::Real
    potential::Real
    edge_flag::Bool ## if 1 then the node is on an edge
    adjacency_list::Array{Array{Real,1}}

end 

mutable struct Lattice

     #=

    =#

    length::Integer
    n_grids::Integer 
    lattice_grid::Array{Node}
end 

# number-> √number* √number==number ? true : return false 

function checkperfsquare(number::Integer)

     #=

    =#

    if √number* √number==number 
        return true 
    else 
        return false
    end 
end 


function make_lattice(lattice::Lattice,L::Integer,n_grids::Integer)

    #=

   =#


   initial_potential=0
   four_flag=1
   if lattice.n_grids>0 && checkperfsquare(lattice.n_grids) 
       nsquare=√lattice.n_grids
       L=lattice.length
       lattice_piece1=[[x,y,initial_potential,four_flag] for x=0:1/nsquare:L/2,y=0:1/nsquare:L]
       lattice_piece2=[[x,y,initial_potential,four_flag] for x=L/2:1/nsquare:L,y=L/2:1/nsquare:L]
       return lattice.lattice_grid=[lattice_piece1 lattice_piece2]
   else 
       error("Use integer which is a perfect square\n")
       return 0
   end 
end 


function make_lattice(lattice::Lattice,L::Integer,n_grids::Integer)

    #=

   =#


   initial_potential=0
   four_flag=1
   if lattice.n_grids>0 && checkperfsquare(lattice.n_grids) 
       nsquare=√lattice.n_grids
       L=lattice.length
       lattice_piece1=[[x,y,initial_potential,four_flag] for x=0:1/nsquare:L/2,y=0:1/nsquare:L]
       lattice_piece2=[[x,y,initial_potential,four_flag] for x=L/2:1/nsquare:L,y=L/2:1/nsquare:L]
       return lattice.lattice_grid=[lattice_piece1 lattice_piece2]
   else 
       error("Use integer which is a perfect square\n")
       return 0
   end 
end 

function make_lattice_node(L::Integer,n_grids::Integer,initial_potential)

    #=

   =#

   default_potential=0
   default_edge_case=0
   lattice=Lattice(L,n_grids,[])
   if lattice.n_grids>0 && checkperfsquare(lattice.n_grids) 
       nsquare=√lattice.n_grids
       L=lattice.length
       step=1/nsquare
       lattice_piece1=[Node(x,y,default_potential,default_edge_case,Array{Real}) for x=0:step:L/2+step,y=0:step:L+step]
       lattice_piece2=[Node(x,y,default_potential,default_edge_case,Array{Real}) for x=L/2:step:L+step,y=L/2:step:L+step]
       return lattice.lattice_grid=[lattice_piece1 lattice_piece2]
   else 
       error("Use integer which is a perfect square\n")
       return 0
   end 
end 


function define_lattice(lattice::Lattice,ϕ::Real)

    #=

    =#

    y_component=lattice.length
    coordinate=1
    potential=3
    for i in lattice.lattice_grid
        if lattice.lattice_grid[i][coordinate][y_component]==y_component
            lattice.lattice_grid[i][potential]==ϕ
        else 
            continue 
        end 
    end 
end 



function neighbor_seek_n_link(lattice::Lattice)
    
    adjacency_list=4
    three_flag=0
    coordinate=1
    flag_position=4
    m,n=size(lattice.lattice_grid)
    for i=0:m, j=0:n
        if lattice.length ∈ lattice.lattice_grid[i,j][coordinate] 

            lattice.lattice_grid[i,j][coordinate][flag_position]
        end

            ## interior element 




    end 

   

end 

function neighbor_seek_n_link(lattice::Lattice)
    
    adjacency_list=4
    three_flag=0
    coordinate=1
    flag_position=4
    x_coordinate=1
    y_coordinate=2
    m,n=size(lattice.lattice_grid)
    for i=0:m, j=0:n

        ## literal edge cases

        ## on border 
        if lattice.length ∈ lattice.lattice_grid[i,j][coordinate] 
            ## on the corner 
        else 
            ## interior element
            push!(lattice.lattice_grid[i,j][adjacency_list],(i-1,j),(i+1,j),(i,j-1),(i,j+1))

    end   

end 

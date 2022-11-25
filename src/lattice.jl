#=
Script: 
Author: Djamil Lakhdar-Hamina
Date:
    Created: 
    Modified: 
Description: 
=#

mutable struct Node{I<:Number,T<:Number}

    #=

    =#

    x_::I
    y_::I
    potential::T
    edge_flag::Bool ## if 1 then the node is on an edge
    # adjacency_list::Array{Real,1}

end 

struct Lattice{I<:Int,X_Y<:Number,T<:Number}

     #=

    =#

    length::I
    n_grids::I 
    lattice_grid::Array{Node{X_Y,T}}
end 

∑(arr)=sum(arr)
L2_norm(arr)=√sum([x^2 for x in arr])

function checkperfsquare(number::Number)

     #=

    =#

    return (floor(√number)^2==number)
end 

function checkifedge(x::Number,y::Number,L::Number)

    #=

    =#

    if (x>=0 || x<=L) && (y>=0 && y<=L)
        return (x==L || x==0 || y==L || y==0) || (x>L/2 && y<L/2)
    end 
    return false
end 

# function checkifedge(x,y,L)

#     #=

#     =#

#     if (x>=0 || x<=L) && (y>=0 && y<=L)
#         if (x==L || x==0 || y==L || y==0) || (x>L/2 && y<L/2)
#             return true 
#         else 
#             return false 
#         end 
#     else 
#         return false 
#     end 
# end 

function make_lattice_node(L::Int,n_grids::Int,initial_potential::Number)

    #=

   =#

   default_potential=0
   if n_grids>0 && checkperfsquare(n_grids) 
    #    nsquare=√n_grids
       incre=L/√n_grids
       lattice_grid=[y==L ? Node{Float64,Float64}(x,y,initial_potential,checkifedge(x,y,L)) : Node{Float64,Float64}(x,y,default_potential,checkifedge(x,y,L)) for x=0-incre:incre:L+incre,y=0-incre:incre:L+incre]
       return Lattice{Int64,Float64,Float64}(L,n_grids,lattice_grid)

   else 
       error("Use integer which is a perfect square\n")
       return 0
   end 
end 
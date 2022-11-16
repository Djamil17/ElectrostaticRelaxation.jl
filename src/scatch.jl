#=
Script: 
Author: Djamil Lakhdar-Hamina
Date:
    Created: 
    Modified: 
Description: 
=#

using PlotlyJS

mutable struct Node 

    #=

    =#

    x_::Real
    y_::Real
    potential::Real
    edge_flag::Bool ## if 1 then the node is on an edge
    # adjacency_list::Array{Real,1}

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

function checkifedge(x,y,L)

    #=

    =#

    if (x>=0 || x<=L) && (y>=0 && y<=L)
        if (x==L || x==0 || y==L || y==0) || (x>L/2 && y<L/2)
            return true 
        else 
            return false 
        end 
    else 
        return false 
    end 
end 

function make_lattice_node(L::Integer,n_grids::Integer,initial_potential::Real)

    #=

   =#

   default_potential=0
   if n_grids>0 && checkperfsquare(n_grids) 
    #    nsquare=√n_grids
       incre=L/√n_grids
       lattice_grid=[y==L ? Node(x,y,initial_potential,checkifedge(x,y,L)) : Node(x,y,default_potential,checkifedge(x,y,L)) for x=0-incre:incre:L+incre,y=0-incre:incre:L+incre]
       return Lattice(L,n_grids,lattice_grid)

   else 
       error("Use integer which is a perfect square\n")
       return 0
   end 
end 


function average_over_neighbors(grid::Array{Node},i,j,a)

    #=

    =#


    return 1/4*(grid[i-1,j].potential+grid[i+1,j].potential+grid[i,j-1].potential+grid[i,j+1].potential)

end 

function relax!(lattice::Lattice,L::Real,n_grids::Integer)

    #=

    =#

        m,n=size(lattice.lattice_grid)
        grid=lattice.lattice_grid
        a=L/√n_grids

        for i=2:n-1,j=2:m-1
            node=grid[i,j]
            # @show node
            if node.edge_flag==false
               node.potential=average_over_neighbors(grid,i,j,a)
            end 
        end 

end 

function relax_dont_do_it(lattice::Lattice,trials::Real)

    #=

    =#

    Δ=0
    while Δ<trials  
        # @show  Δ
        relax!(lattice) 
        # @show lattice.lattice_grid
        Δ=Δ+1
    end
end 

function topographical_map(lattice::Lattice)

    z_data=[node.potential for node in lattice.lattice_grid[2:end-1,2:end-1]]

    return surface(
        x=[node.x_ for node in lattice.lattice_grid[2:end-1,2:end-1]],
        y=[node.y_ for node in lattice.lattice_grid[2:end-1,2:end-1]],
        z=z_data,
        contours_z=attr(
            show=true,
            usecolormap=true,
            highlightcolor="limegreen",
            project_z=true
        )
    )

end

function animate(lattice::Lattice,trials::Integer,n_grids::Integer)

    trace = topographical_map(lattice)
    n_frames = trials
    frames  = Vector{PlotlyFrame}(undef, n_frames)
    for k in 1:n_frames
        # @show  Δ
        relax!(lattice,lattice.length,n_grids) 
        frames[k]=frame(data=(attr(z=[node.potential for node in lattice.lattice_grid[2:end-1,2:end-1]])),
        layout=attr(title_text="Iteration $k"), #update title
        name="fr$k", #frame name; it is passed to slider  
        # this means that the above data update the first trace (here the unique one) 
        traces=[0]) 
    end


    updatemenus = [attr(type="buttons", 
                        active=0,
                        y=1.2,  #(x,y) button position 
                        x=1.2,
                        buttons=[attr(label="Play",
                                    method="animate",
                                    args=[nothing,
                                            attr(frame=attr(duration=1, 
                                                            redraw=true),
                                                transition=attr(duration=0),
                                                fromcurrent=true,
                                                mode="immediate"
                                                            )])])];


    sliders = [attr(active=0, 
                    minorticklen=0,
                    
                    steps=[attr(label="f$k",
                                method="animate",
                                args=[["fr$k"], # match the frame[:name]
                                    attr(mode="immediate",
                                        transition=attr(duration=1),
                                        frame=attr(duration=1, 
                                                    redraw=true))
                                    ]) for k in 1:n_frames ]
                )];    

    layout = Layout(title_text="Finding Pontential Via Relaxation", title_x="x",
        width=1000, height=1000,
                xaxis_range=[0, lattice.length+5], 
                yaxis_range=[0, lattice.length+5],
                updatemenus=updatemenus,
                sliders=sliders)

    Plot(trace, layout, frames)

end


# function estimate_error(lattice::Lattice)
#   @show 
# end 

# function main(length,n_grids,intitial_potential, trials)

#     lattice=make_lattice_node(length,n_grids,intitial_potential)
#     animate(lattice,trials)

# end 


# frame = 1

# trace = topographical_map(lattice)
# n_frames = trials
# frames  = Vector{PlotlyFrame}(undef, n_frames)


length=1000
n_grids=100
potential=100
# latt=make_lattice_node(length,n_grids,potential)
# trace=topographical_map(latt)
# plt=plot(trace)
# for k in 1:n_frames
#     # @show  Δ
#     relax!(latt,latt.length,n_grids) 
#     react!(plt,trace,layout)
# end


latt=make_lattice_node(length,n_grids,potential)

@animate for i ∈ 1:n

    plot(topographical_map(latt))
    relax!(latt,length, n_grids)
end
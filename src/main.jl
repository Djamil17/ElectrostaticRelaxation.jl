#=
Script: 
Author: Djamil Lakhdar-Hamina
Date:
    Created: 
    Modified: 
Description: 
=#

using PlotlyJS
using Plots

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

# number-> √number* √number==number ? true : return false 

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


function average_over_neighbors(grid::Array{Node{Float64,Float64}},i::Int,j::Int)

    #=

    =#


    return 1/4*(grid[i-1,j].potential+grid[i+1,j].potential+grid[i,j-1].potential+grid[i,j+1].potential)

end 

function relax!(lattice::Lattice)

    #=

    =#

        m,n=size(lattice.lattice_grid)

        for i=2:n-1,j=2:m-1
            node=lattice.lattice_grid[i,j]
            # @show node
            if node.edge_flag==false
               node.potential=average_over_neighbors(lattice.lattice_grid,i,j)
            end 
        end 

end 

function relax(lattice::Lattice)::Lattice

    #=

    =#

        lattice_copy=deepcopy(lattice)
        m,n=size(lattice.lattice_grid)

        for i=2:n-1,j=2:m-1
            node=lattice_copy.lattice_grid[i,j]
            # @show node
            if node.edge_flag==false
               node.potential=average_over_neighbors(lattice.lattice_grid[i,j],i,j)
            end 
        end 

        return lattice_copy

end 

function estimate_potential(lattice::Lattice,tolerance::Number,max_trials::Int=10000000)

    #=

    =#

    Δ=0
    t=0
    while Δ<tolerance && t<max_trials 
        L2_0=L2_norm([node.potential for node in lattice.lattice_grid[2:end-1,2:end-1]])
        relax!(lattice) 
        L2_1=L2_norm([node.potential for node in lattice.lattice_grid[2:end-1,2:end-1]])
        Δ=L2_1/L2_0
        t=t+1
    end
end 

function estimate_potential_point(lattice::Lattice,tolerance::Number,x::Number,y::Number,max_trials::Int=10000000)

    #=

    =#

    Δ=0
    t=0
    while Δ<tolerance && t<max_trials 
        L2_0=L2_norm([node.potential for node in lattice.lattice_grid[2:end-1,2:end-1]])
        relax!(lattice) 
        L2_1=L2_norm([node.potential for node in lattice.lattice_grid[2:end-1,2:end-1]])
        Δ=L2_1/L2_0
        t=t+1
    end
end 

function topographical_map(lattice::Lattice)
    z_data=[node.potential for node in lattice.lattice_grid[2:end-1,2:end-1]]

    return PlotlyJS.surface(
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

function animate_realtime(lattice::Lattice,trials::Integer)

    trace = topographical_map(lattice)
    n_frames = trials
    frames  = Vector{PlotlyFrame}(undef, n_frames)
    for k in 1:n_frames
        # @show  Δ
        relax!(lattice) 
        frames[k]=frame(data=[attr(z=[node.potential for node in lattice.lattice_grid[2:end-1,2:end-1]])],
                        layout=attr(title_text="Iteration $k"), #update title
                        name="fr$k", #frame name; it is passed to slider 
                        traces=[0] # this means that the above data update the first trace (here the unique one) 
        ) 
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
                        scene=attr(xaxis_range=[0, lattice.length], 
                        yaxis_range=[0, lattice.length]),
                        updatemenus=updatemenus,
                        sliders=sliders)

    Plot(trace, layout, frames)

end

function animate_save(lattice::Lattice,n_frames::Int64)

    fig = Plot(topographical_map(lattice), 
           PlotlyJS.Layout(title_text="Finding Pontential Via Relaxation", title_x=0.5,
                width=100, height=100,
                scene=attr(xaxis_range=[0, lattice.length], 
                yaxis_range=[0, lattice.length]),))

    fnames=String[]
    for k in 1:n_frames
        relax!(lattice) 
        update(fig, Dict(:z=>[[node.potential for node in lattice.lattice_grid[2:end-1,2:end-1]]]),
        layout=PlotlyJS.Layout(title_text="Iteration $k"))
        filename=lpad(k, 6, "0")*".png"
        push!(fnames, filename)
        PlotlyJS.savefig(fig,"/tmp/"*filename, width=1000, height=1000, scale=1) #tmp, a folder where the frames are saved
    end
    anim = Plots.Animation("/tmp", fnames)
    # Plots.buildanimation(anim, "your.gif", fps = 12, show_msg=false)
    Plots.buildanimation(anim, "your.mp4", fps = 2, show_msg=false)  
    for file in fnames
        rm("/tmp/"*file)
    end 

end 

function main()

    

end 
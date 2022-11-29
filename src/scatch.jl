#=
Script: 
Author: Djamil Lakhdar-Hamina
Date:
    Created: 
    Modified: 
Description: 

TODO: 

1. optimize iterating, recreate iteration space
2. collate mesh and pointwise methods into a single dictating function 
3. do error analysis pointwise and aggregate
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

struct Lattice{T<:Number,I<:Int,X_Y<:Number}

     #=

    =#

    length::T
    n_grids::I 
    lattice_grid::Array{Node{X_Y,T}}
end 

# number-> √number* √number==number ? true : return false 

∑(arr)=sum(arr)
L2_norm(arr)=√sum([x^2 for x in arr])
mean_diff(arr)=sum(arr)/size(arr)


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

function potential_meshgrid(L::Int,n_grids::Int,initial_potential::Number)

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


function estimate_mesh_potential_L2(lattice::Lattice,tolerance::Number,max_trials::Int=10000,error_analysis::Bool=true)

    #=

    =#

    t=0
    Δ=tolerance+1
    while Δ>tolerance 
        L2_0=L2_norm([node.potential for node in lattice.lattice_grid[2:end-1,2:end-1]])
        relax!(lattice) 
        L2_1=L2_norm([node.potential for node in lattice.lattice_grid[2:end-1,2:end-1]])
        Δ=(L2_1-L2_0)/L2_0
        # @show Δ
        if error_analysis==true
            error_sum+=Δ
        end 
        t+=1
        if t==max_trials 
            print("max trials admitted")
            break 
        end 
    end

    if error_analysis==true
        return error_sum/t
    end 

end 

function estimate_mesh_potential_mean_diff(lattice::Lattice,tolerance::Number,max_trials::Int=10000,error_analysis::Bool=true)

    #=

    =#

    t=0
    Δ=tolerance+1
    while Δ>tolerance 

      
        mean_0=mean_diff([node.potential for node in lattice.lattice_grid[2:end-1,2:end-1]])
        relax!(lattice) 
        mean_1=L2_norm([node.potential for node in lattice.lattice_grid[2:end-1,2:end-1]])
        Δ=(mean_1-mean_0)/mean_0
        if error_analysis==true
            error_sum+=Δ
        end 
        # @show Δ
        t+=1
        if t==max_trials 
            print("max trials admitted")
            break 
        end 
    end

    if error_analysis==true
        return error_sum/t
    end 
end 


function estimate_pointwise_potential_L2(lattice::Lattice,tolerance::Number,x::Number,y::Number,max_trials::Int=10000000)::Number

    #=

    =#

    if (x<0 || x>lattice.length) && (y<0 || y>lattice.length)
        print("Coordinates ($x,$y) are not in interval of the lattice")
        exit(1)
    end 

    estimate_mesh_potential_L2(lattice,tolerance,max_trials)
    for node in lattice.lattice_grid[2:end-1,2:end-1]
        if node.x_==x && node.y_==y
            return node.potential 
        end 
    end 
        
end 

function estimate_pointwise_potential_diff(lattice::Lattice,percent_error::Number,x::Number,y::Number,max_trials::Int=10000000,waittime::Int=5)::Number

    #=

         estimate_pointwise_potential_diff((lattice::Lattice,percent_error::Number,x::Number,y::Number,max_trials::Int=10000000,waittime::Int=5)::Number

    Compute the potential of a single point in the lattice grid. The algorithm is iterative and continues until the difference bewteen value of iteration t and 
    t+1 is less than a certain percent percent i.e. (val(t)-val(t+1))/val*100 < percent

    # Examples
    ```julia-repl
    julia> estimate_pointwise_potential_diff(lattice, 1,0.75 ,0.75)

    ```
    =#

    if (x<0 || x>lattice.length) && (y<0 || y>lattice.length)
        error("Coordinates ($x,$y) are not in interval of the lattice") 
    end 

    error_val=percent_error+1
    zero_offset=.00000000001
    tmp=0.0
    node_potential=0.0
    while error_val>percent_error
        for node in lattice.lattice_grid[2:end-1,2:end-1]
            if node.x_==x && node.y_==y
                tmp=node.potential
                # @show tmp
                break
            end 
        end
        ## This loop exists to prevent tmp being zero so that the error value at beginning is 0%
        i=0
        while i<waittime
            relax!(lattice)
            i+=1
        end 
        for node in lattice.lattice_grid[2:end-1,2:end-1]
            if node.x_==x && node.y_==y
                node_potential=node.potential
                error_val=(node.potential-tmp)/(tmp+zero_offset)*100
                # @show error_val
            end 
        end
    end 
    return node_potential
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

function animate_save(lattice::Lattice,n_frames::Int64,video_name::String, video_type::String,fps::Integer)

    fig = Plot(topographical_map(lattice), 
           PlotlyJS.Layout(title_text="Finding Pontential Via Relaxation", title_x=0.5,
                width=100, height=100,
                scene=attr(xaxis_range=[0, lattice.length], 
                yaxis_range=[0, lattice.length])))

    camera = attr(
                    eye=attr(x=-2, y=-1, z=0.1)
                )

    relayout!(fig, scene_camera=camera)


    fnames=String[]
    for k in 1:n_frames
        relax!(lattice) 
        update!(fig, Dict(:z=>[[node.potential for node in lattice.lattice_grid[2:end-1,2:end-1]]]),
        layout=PlotlyJS.Layout(title_text="Iteration $k"))
        filename=lpad(k, 6, "0")*".png"
        push!(fnames, filename)
        PlotlyJS.savefig(fig,"/tmp/"*filename, width=1000, height=1000, scale=1) #tmp, a folder where the frames are saved
    end
    anim = Plots.Animation("/tmp", fnames)

    if video_type=="gif"
        Plots.buildanimation(anim, "$video_name.gif", fps = fps, show_msg=false)
    elseif video_type=="mp4"
        Plots.buildanimation(anim, "$video_name.mp4", fps = fps, show_msg=false)  
    else 
        print("ERROR: Choose either mp4 or gif format")
    end 

    for file in fnames
        rm("/tmp/"*file)
    end 

end 

function main(L::Number==1, ϕ::Number==1,ngrid::Number=16)

    ## initialize different meshes 

    ## for aggregates 

    ## for mean diff
    lattice_low_grain0=potential_meshgrid(L,ngrid,ϕ)
    lattice_mid_grain0=potential_meshgrid(L,ngrid*4,ϕ)
    lattice_fine_grain0=potential_meshgrid(L,ngrd*64,ϕ)

    ## for l2 norm 
    lattice_low_grain1=potential_meshgrid(L,ngrid,ϕ)
    lattice_mid_grain1=potential_meshgrid(L,ngrid*4,ϕ)
    lattice_fine_grain1=potential_meshgrid(L,ngrd*64,ϕ)

    ## for pointwise 
    lattice_low_grain2=potential_meshgrid(L,ngrid,ϕ)
    lattice_mid_grain2=potential_meshgrid(L,ngrid*4,ϕ)
    lattice_fine_grain2=potential_meshgrid(L,ngrd*64,ϕ)

    # test aggregate measure of error mean diff and L2_0

    estimate_mesh_potential_mean_diff(lattice_low_grain0,1e-12)
    estimate_mesh_potential_mean_diff(lattice_mid_grain0,1e-12)
    estimate_mesh_potential_mean_diff(lattice_fine_grain0,1e-12)

    estimate_mesh_potential_L2(lattice_low_grain1,1e-12)
    estimate_mesh_potential_L2(lattice_mid_grain1,1e-12)
    estimate_mesh_potential_L2(lattice_fine_grain1,1e-12)

    ## testpointwise aggregate 

    estimate_pointwise_potential_diff(lattice_low_grain2,1,.75,.75)
    estimate_pointwise_potential_diff(lattice_mid_grain2,1,.75,.75)
    estimate_pointwise_potential_diff(lattice_fine_grain2,1,.75,.75)


end 


main()
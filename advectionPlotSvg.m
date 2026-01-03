function [file_name_no_ext,file_name,file_name_no_folder] = advectionPlotSvg(particlePosition,muVal,folderPath,darkmode,timeDisplay,frameNumber,vortexLocations,figureSizeArray,options)
%> Code Description:
%     Makes .svg of plot of particle array
%
%> Inputs:
%     particlePosition:           Particle array for a single time,
%                                 flattened to 1 dim
%
%     muVal:                      Mu value to appear in the title of the plot
%
%     folderPath:                 Folder where the resulting .svg file will be stored
%
%     darkmode:                   Control darkmode/lightmode of plot (Default: 1)
%
%     timeDisplay:                Time value in seconds to appear in the title
%                                 of the plot (Default: 0)
%
%     frameNumber:                Frame number for saving name purposes
%                                 (Default: 0)
%
%     vortexLocations:            Locations of vortexes in complex notation
%                                 (Default: [0.5+0i; -0.5+0i])
%
%     figureSizeArray:            Figure size in inches of saved .svg
%                                 (Default: [1 1 6 4], 6"x4" inches)
%
%     options:                    Plotting options that can be called by
%                                 name-value,
%                                   .pointSize       -> size of particles (Default: 2.6)
%                                   .pointColor      -> color of particles (Default: "#7d32a8")
%                                   .vortexSize      -> size of vortex marker (Default: 5)
%                                   .vortexMarker    -> vortex marker type (Default: '+')
%                                   .vortexLineWidth -> vortex marker line size (Default: 1.2)
%                                   .xticksArray     -> x-axis ticks array (Default: [-1:0.2:1])
%                                   .yticksArray     -> y-axis ticks array (Default: [-1:0.2:1])
%                                   .displayAxis     -> controls showing axes,
%                                                       0: false, 1: true (Default: 1)
%                                   .saveBaseName    -> base name of .svg/img files
%                                                       (Default: "Frame")
%
%> Outputs:
%     file_name_no_ext:           Full path of saved .svg plot without ext
%
%     file_name:                  Full path of saved .svg plot
%
%     file_name_no_folder:        Filename, no path
%
%> Harrison Ross Hibbett (harrison_hibbett@alumni.brown.edu) 2025
    arguments
        particlePosition double
        muVal double
        folderPath string = string(pwd)
        darkmode logical = 1
        timeDisplay double = 0
        frameNumber double = 0
        vortexLocations (:,1) double = [0.5+0i;-0.5+0i]
        figureSizeArray double = [1 1 6 4]
        options.pointSize {mustBeNumeric} = 2.6
        options.pointColor = "#7d32a8"
        options.vortexSize = 5
        options.vortexMarker = "+"
        options.vortexLineWidth = 1.2
        options.xticksArray = [-1:0.2:1]
        options.yticksArray = [-1:0.2:1]
        options.displayAxes = 1
        options.saveBaseName = "Frame"
        % options.exportType = ".svg"
    end

    f_cur = figure('Visible','off');

    % Set figure size
    f_cur.Units = 'inches';
    f_cur.Position = figureSizeArray;   

    if darkmode
        theme(f_cur,"dark")
        stableElemColor = [1,1,1];
        stableElemColor2 = [2,2,2]./255;
        backgroundColor = [0,0,0];
    else
        theme(f_cur,"light")
        stableElemColor = [0,0,0];
        stableElemColor2 = [254,254,254]./255;
        backgroundColor = [1,1,1];
    end

    % Plot main circle
    viscircles([0,0],1,'Color',stableElemColor, 'EnhanceVisibility', false);

    ax1 = gca;
    hold on

    % Plot vortex locations
    for i = 1:length(vortexLocations)
        plot(real(vortexLocations(i)),imag(vortexLocations(i)),'Marker',options.vortexMarker,'Color',stableElemColor,'LineWidth',options.vortexLineWidth)
    end

    xlim([-1.05 1.05])
    ylim([-1.05 1.05])
    pbaspect(ax1,[1 1 1]);
    xticks(options.xticksArray)
    yticks(options.yticksArray)
    set(gca,'YTickLabel',[]);
    set(gca,'XTickLabel',[]);

    % Plot Particles
    x_ps = real(particlePosition);
    y_ps = imag(particlePosition);
    plot(x_ps,y_ps,'.','MarkerSize',options.pointSize,'Color',options.pointColor)

    % Frame Title
    time_display = sprintfc('%0.2f',timeDisplay);
    subtitle("$\mu =$ " + muVal +",$\quad t =$ " + time_display, 'FontSize',16,'Interpreter','latex')

    % Add Text in corner to keep image from resizing under certain titles
    t_text = text(-1,1.159,"P","FontSize",16,"FontWeight","bold","Color",stableElemColor2);

    % Format Figure
    set(gca,'linewidth',1) 
    set(gca, 'Layer', 'bottom') 
    if options.displayAxes
        set(groot, 'defaultAxesXColor', stableElemColor, ...
                       'defaultAxesYColor', stableElemColor, ...
                       'defaultAxesZColor', stableElemColor);
        ax1.XColor = stableElemColor;
        ax1.YColor = stableElemColor;
        ax1.ZColor = stableElemColor;
        box(ax1,"on");
        ax1.BoxStyle = 'full';
    else
        set(groot, 'defaultAxesXColor', stableElemColor2, ...
                       'defaultAxesYColor', stableElemColor2, ...
                       'defaultAxesZColor', stableElemColor2);
        ax1.XColor = stableElemColor2;
        ax1.YColor = stableElemColor2;
        ax1.ZColor = stableElemColor2;
    end
    set(gca, 'color', backgroundColor)
    set(gcf, 'color', backgroundColor)
    
    % Create Folder (if needed)
    if ~exist(folderPath, 'dir')
       mkdir(folderPath)
    end
    
    % Export Image
    base_name = options.saveBaseName;
    figure_file_name = sprintf( '%04d', frameNumber) + base_name;
    file_name_no_folder = figure_file_name;
    file_type = ".svg";
    file_name_no_ext = fullfile(folderPath, figure_file_name);
    file_name = file_name_no_ext + file_type;

    % Save the figure as an SVG file
    exportgraphics(f_cur, file_name, 'BackgroundColor', backgroundColor, 'ContentType', 'vector');

    close(f_cur);
end
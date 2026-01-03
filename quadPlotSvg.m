function [file_name_no_ext,file_name,file_name_no_folder] = quadPlotSvg(particlePositionCell,folderPath,darkmode,timeDisplay,frameNumber,vortexLocations,figureSizeArray,options)
%> Code Description:
%     Makes quad plot exported as an .svg plot of 4 given particle arrays
%
%> Inputs:
%     particlePositionCell:        Cell array of 4 particle time arrays
%
%     folderPath:                  Folder where the resulting .svg file will be stored
%
%     darkmode:                    Control darkmode/lightmode of plot (Default: 1)
%
%     timeDisplay:                 Time value in seconds to appear in the title
%                                  of the plot (Default: 0)
%
%     frameNumber:                 Frame number for saving name purposes
%                                  (Default: 0)
%
%     vortexLocations:             Locations of vortexes in complex notation.
%                                  It is assumed the same for all 4 plots.
%                                  (Default: [0.5+0i; -0.5+0i])
%
%     figureSizeArray:             Figure size in inches of saved .svg
%                                  (Default: [1 1 10 10], 10"x10" inches)
%
%     options:                     Plotting options that can be called by
%                                  name-value,
%                                    .pointSize       -> size of particles (Default: 2.6)
%                                    .pointColor      -> color of particles (Default: "#7d32a8")
%                                    .vortexSize      -> size of vortex marker (Default: 5)
%                                    .vortexMarker    -> vortex marker type (Default: '+')
%                                    .vortexLineWidth -> vortex marker line size (Default: 1.2)
%                                    .displayAxis     -> controls showing axes,
%                                                        0: false, 1: true (Default: 0)
%                                    .saveBaseName    -> base name of .svg/img files
%                                                        (Default: "Frame")
%
%> Outputs:
%     file_name_no_ext:            Full path of saved .svg plot without ext
%
%     file_name:                   Full path of saved .svg plot
%
%     file_name_no_folder:         Filename, no path
%
%> Harrison Ross Hibbett (harrison_hibbett@alumni.brown.edu) 2025
    arguments
        particlePositionCell
        folderPath string = string(pwd)
        darkmode logical = 0
        timeDisplay double = 0
        frameNumber double = 0
        vortexLocations (:,1) double = [0.5+0i;-0.5+0i]
        figureSizeArray = [1 1 10 10]
        options.pointSize {mustBeNumeric} = 6.6
        options.pointColor = "#7d32a8"
        options.vortexSize = 5
        options.vortexMarker = "+"
        options.vortexLineWidth = 1.2
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
    
    posSub = [0.015,0.515;0.515,0.515;0.015,0.015;0.515,0.015];
    labels = {'(a)','(b)','(c)','(d)'};
    
    for plot_i = 1:4    
        ax = axes('Position', [posSub(plot_i,:), 0.47, 0.47]);
    
        particlePosition = particlePositionCell{plot_i}(:,frameNumber+1);
    
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
        % xticks(options.xticksArray)
        % yticks(options.yticksArray)
        set(gca,'YTickLabel',[]);
        set(gca,'XTickLabel',[]);
        
        % Plot Particles
        x_ps = real(particlePosition);
        y_ps = imag(particlePosition);
        plot(x_ps,y_ps,'.','MarkerSize',options.pointSize,'Color',options.pointColor)
        
         text(ax, 0.9, 0.975, labels{plot_i}, ...
            'Units','normalized', ...
            'HorizontalAlignment','right', ...
            'VerticalAlignment','top', ...
            'FontWeight','bold', ...
            'FontAngle','italic',...
            'Color',stableElemColor,...
            'FontSize', 16);
         
        % Format Figure
        set(gca,'linewidth',1) 
        set(gca, 'Layer', 'bottom') 
        set(groot, 'defaultAxesXColor', stableElemColor2, ...
                       'defaultAxesYColor', stableElemColor2, ...
                       'defaultAxesZColor', stableElemColor2);
        ax1.XColor = stableElemColor2;
        ax1.YColor = stableElemColor2;
        ax1.ZColor = stableElemColor2;
        set(gca, 'color', backgroundColor)
        set(gcf, 'color', backgroundColor)
    end
    
    axT = axes('Position',[0 0 1 1], 'Visible','off');
    time_display = sprintfc('%0.2f',timeDisplay);
    title(axT, "$t =$ " + time_display, ...
          'Visible','on', ...
          'Units','normalized', ...
          'FontSize',36,...
          'Interpreter','latex',...
          'Position',[0.59, 0.01, 0], ...  
          'HorizontalAlignment','right');

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
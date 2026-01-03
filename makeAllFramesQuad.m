function makeAllFramesQuad(particlePositionCell,outputFolder,numFrames,maxTime,lightOrDark,storageType,widthOrHeight,pixelsDist,figureSizeArray,vortexLocations,options)
%> Code Description:
%     Makes all frames of the mapping array via calling quadPlotSvg.m.
%     Files will first be made as .svg, then converted to an image file.
%     Dependent on command line programs "rsvg-convert" and "magick".
%
%> Inputs:
%     particlePositionCell:     Cell array of 4 particle time arrays
%
%     outputFolder:             Folder where the resulting subfolders of
%                               SVGs and image files will be stored
%
%     numFrames:                Total number of frames
%
%     maxTime:                  Max time of the simulation (Default: 2)
%
%     lightOrDark:              Light/dark mode.
%                                 'b' → both
%                                 'l' → light only
%                                 'd' → dark only (Default: 'b')
%
%     storageType:              Image file type.
%                                 'b' → both
%                                 'j' → JPG only
%                                 'p' → PNG only
%                               Dependent on command line programs
%                               "rsvg-convert" and "magick"
%                               (Default: 'j')
%
%     widthOrHeight:            Choice of size parameter for conversion from
%                               .svg to image file.
%                                 'w' → width
%                                 'h' → height
%                               (Default: 'w')
%
%     figureSizeArray:          Figure size in inches of saved .svg
%                               (Default: [1 1 10 10], 10"×10" inches)
%
%     options:                  Plotting options (name–value pairs):
%                                   .pointSize       → size of particles (Default: 2.6)
%                                   .pointColor      → color of particles (Default: "#7d32a8")
%                                   .vortexSize      → size of vortex marker (Default: 5)
%                                   .vortexMarker    → vortex marker type (Default: '+')
%                                   .vortexLineWidth → vortex marker line width (Default: 1.2)
%                                   .displayAxis     → show axes:
%                                                         0: false
%                                                         1: true
%                                                       (Default: 0)
%                                   .saveBaseName    → base name of .svg/image files
%                                                       (Default: "Frame")
%
%> Harrison Ross Hibbett (harrison_hibbett@alumni.brown.edu) 2025
    arguments
        particlePositionCell 
        outputFolder string
        numFrames double
        maxTime double = 2
        lightOrDark string = "b"
        storageType string = "j"
        widthOrHeight string = "w"
        pixelsDist double = 1024
        figureSizeArray = [1 1 10 10]
        vortexLocations (:,1) double = [0.5+0i;-0.5+0i]
        options.pointSize {mustBeNumeric} = 6.6
        options.pointColor = "#7d32a8"
        options.vortexSize = 5
        options.vortexMarker = "+"
        options.vortexLineWidth = 1.2
        options.saveBaseName = "Frame"
    end

    % Put optional name-value pairs from original function call into format
    % that can be passed to inside function calls
    fn = fieldnames(options);
    vals = struct2cell(options);
    nvPairs = reshape([fn'; vals'],1,[]);
    
    % If lightOrDark = "b" : both create subFolders of each svg
    if lightOrDark == "b"
        lightFramesSvg = fullfile(outputFolder, 'LightFramesSvg');
        darkFramesSvg = fullfile(outputFolder, 'DarkFramesSvg');
        lightFramesImgs = fullfile(outputFolder, 'LightFramesImgs');
        darkFramesImgs = fullfile(outputFolder, 'DarkFramesImgs');

        % Create Folder
        if ~exist(lightFramesSvg, 'dir')
           mkdir(lightFramesSvg)
        end
        if ~exist(darkFramesSvg, 'dir')
           mkdir(darkFramesSvg)
        end
        if ~exist(lightFramesImgs, 'dir')
           mkdir(lightFramesImgs)
        end
        if ~exist(darkFramesImgs, 'dir')
           mkdir(darkFramesImgs)
        end
        
        if size(particlePositionCell{1},2) ~= numFrames
            error("Either paricle array in inproper format or incorrect numFrames given...")
        else
            timeArray = linspace(0,maxTime,numFrames);
            for i = 1:numFrames
                timeDisplay = timeArray(i);
                % LightMode First
                [outputFileNameNoExt,outputFileName,outputFileNameSolo] = quadPlotSvg(particlePositionCell,lightFramesSvg,0,timeDisplay,i-1,vortexLocations,figureSizeArray,nvPairs{:});
                outputFile = fullfile(lightFramesImgs,outputFileNameSolo);
                svgToImgs(outputFile,outputFileName,storageType,widthOrHeight,pixelsDist)
                % DarkMode Second
                [outputFileNameNoExt,outputFileName,outputFileNameSolo] = quadPlotSvg(particlePositionCell,darkFramesSvg,1,timeDisplay,i-1,vortexLocations,figureSizeArray,nvPairs{:});
                outputFile = fullfile(darkFramesImgs,outputFileNameSolo);
                svgToImgs(outputFile,outputFileName,storageType,widthOrHeight,pixelsDist)
            end
        end
    elseif lightOrDark == 'l'
        lightFramesSvg = fullfile(outputFolder, 'LightFramesSvg');
        lightFramesImgs = fullfile(outputFolder, 'LightFramesImgs');
        % Create Folder
        if ~exist(lightFramesSvg, 'dir')
           mkdir(lightFramesSvg)
        end
        if ~exist(lightFramesImgs, 'dir')
           mkdir(lightFramesImgs)
        end

        if size(particlePositionCell{1},2) ~= numFrames
            error("Either paricle array in inproper format or incorrect numFrames given...")
        else
            timeArray = linspace(0,maxTime,numFrames);
            for i = 1:numFrames
                timeDisplay = timeArray(i);
                % LightMode only
                [outputFileNameNoExt,outputFileName,outputFileNameSolo] = quadPlotSvg(particlePositionCell,lightFramesSvg,0,timeDisplay,i-1,vortexLocations,figureSizeArray,nvPairs{:});
                outputFile = fullfile(lightFramesImgs,outputFileNameSolo);
                svgToImgs(outputFile,outputFileName,storageType,widthOrHeight,pixelsDist)
            end
        end

    elseif lightOrDark == 'd'
        darkFramesSvg = fullfile(outputFolder, 'DarkFramesSvg');
        darkFramesImgs = fullfile(outputFolder, 'DarkFramesImgs');
        % Create Folder
        if ~exist(darkFramesSvg, 'dir')
           mkdir(darkFramesSvg)
        end
        if ~exist(darkFramesImgs, 'dir')
           mkdir(darkFramesImgs)
        end

        if size(particlePositionCell{1},2) ~= numFrames
            error("Either paricle array in inproper format or incorrect numFrames given...")
        else
            timeArray = linspace(0,maxTime,numFrames);
            for i = 1:numFrames
                timeDisplay = timeArray(i);
                % DarkMode only
                [outputFileNameNoExt,outputFileName,outputFileNameSolo] = quadPlotSvg(particlePositionCell,darkFramesSvg,1,timeDisplay,i-1,vortexLocations,figureSizeArray,nvPairs{:});
                outputFile = fullfile(darkFramesImgs,outputFileNameSolo);
                svgToImgs(outputFile,outputFileName,storageType,widthOrHeight,pixelsDist)
            end
        end

    else
        error("lightOrDark input value not allowed, should be 'b', 'l', or 'd' ");
    end



end


function makeAllFrames(particleArray,outputFolder,plottingStruct,lightOrDark,storageType,widthOrHeight,pixelsDist,figureSizeArray,options)
%> Code Description:
%     Makes all frames of the mapping array via calling advectionPlotSvg.m.
%     Files will first be made as .svg, then converted to an image file.
%     Dependent on command line programs "rsvg-convert" and "magick"
%
%> Inputs:
%     particleArray:              Particle array for each time,
%                                 flattened to 1 dim for particle locations,
%                                 2nd dim is time, elsewhere called
%                                 particleArrayTimes
%
%     outputFolder:               Folder where the resulting subfolders of
%                                 svgs and image files will be stored
%
%     plottingStruct:             Relevant info to be passing to
%                                 associated plotting functions, an output
%                                 of advectMapping.m
%
%     lightOrDark:                Light/dark mode. 'b': both, 'l': light only,
%                                 'd': dark only (Default: 'b')
%
%     storageType:                Image file type, 'b': both, 'j': jpg only,
%                                 'p': png only. Dependent on command line
%                                 programs "rsvg-convert" and "magick"
%                                 (Default: 'j')
%
%     widthOrHeight:              Choice of size parameters for conversion to
%                                 image file from .svg, 'w': width, 'h': height
%                                 (Default: 'w')
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
%                                   .displayAxes     -> controls showing axes,
%                                                       0: false, 1: true (Default: 1)
%                                   .saveBaseName    -> base name of .svg/img files
%                                                       (Default: "Frame")
%
%> Harrison Ross Hibbett (harrison_hibbett@alumni.brown.edu) 2025
    arguments
        particleArray string
        outputFolder string
        plottingStruct struct
        lightOrDark string = "b"  % 'b': both, 'l': light only, 'd': dark only
        storageType string = "j"  % 'b': both, 'j': jpg only, 'p': png only
        widthOrHeight string = "w"
        pixelsDist double = 512
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
    end

    % Unpack plottingStruct
    frameRate = plottingStruct.frameRate;
    maxTime = plottingStruct.maxTime;
    numFrames = (frameRate*maxTime) + 1;
    vortexLocations = plottingStruct.vortexLocations;
    muValue = plottingStruct.muValue;

    fprintf("makeAllFrames called with:  outputFolder=%s, lightOrDark=%s storageType=%s\n  to make make a total of %g frames", ...
    outputFolder, lightOrDark, storageType, numFrames);

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
        
        if size(particleArray,2) ~= numFrames
            error("Either paricle array in inproper format or incorrect numFrames given...")
        else
            timeArray = linspace(0,maxTime,numFrames);
            for i = 1:numFrames
                timeDisplay = timeArray(i);
                particlePos = particleArray(:,i);
                % LightMode First
                [outputFileNameNoExt,outputFileName,outputFileNameSolo] = advectionPlotSvg(particlePos,muValue,lightFramesSvg,0,timeDisplay,i-1,vortexLocations,figureSizeArray,nvPairs{:});
                outputFile = fullfile(lightFramesImgs,outputFileNameSolo);
                svgToImgs(outputFile,outputFileName,storageType,widthOrHeight,pixelsDist)
                % DarkMode Second
                [outputFileNameNoExt,outputFileName,outputFileNameSolo] = advectionPlotSvg(particlePos,muValue,darkFramesSvg,1,timeDisplay,i-1,vortexLocations,figureSizeArray,nvPairs{:});
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

        if size(particleArray,2) ~= numFrames
            error("Either paricle array in inproper format or incorrect numFrames given...")
        else
            timeArray = linspace(0,maxTime,numFrames);
            for i = 1:numFrames
                timeDisplay = timeArray(i);
                particlePos = particleArray(:,i);
                % LightMode only
                [outputFileNameNoExt,outputFileName,outputFileNameSolo] = advectionPlotSvg(particlePos,muValue,lightFramesSvg,0,timeDisplay,i-1,vortexLocations,figureSizeArray,nvPairs{:});
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

        if size(particleArray,2) ~= numFrames
            error("Either paricle array in inproper format or incorrect numFrames given...")
        else
            timeArray = linspace(0,maxTime,numFrames);
            for i = 1:numFrames
                timeDisplay = timeArray(i);
                particlePos = particleArray(:,i);
                % DarkMode only
                [outputFileNameNoExt,outputFileName,outputFileNameSolo] = advectionPlotSvg(particlePos,muValue,darkFramesSvg,1,timeDisplay,i-1,vortexLocations,figureSizeArray,nvPairs{:});
                outputFile = fullfile(darkFramesImgs,outputFileNameSolo);
                svgToImgs(outputFile,outputFileName,storageType,widthOrHeight,pixelsDist)
            end
        end

    else
        error("lightOrDark input value not allowed, should be 'b', 'l', or 'd' ");
    end



end
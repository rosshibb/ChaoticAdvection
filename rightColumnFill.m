function rightColumnFill(folderPath, expectedColor, checkNumCol, allowedDiff)
%> Code Description:
%     Paints over black bar that can sometimes occur when converting svgs
%     to images. Looks at every image in a folder and looks at the right
%     column of each image, compares it expected background color, and
%     calls FFMPEG to add necessary strip of that color to the right side.
%
%> Inputs:
%     folderPath:      Path to folder of images
%
%     expectedColor:  Expected background color in RGB
%                     [0-255, 0-255, 0-255] format
%                     (Default: [255 255 255])
%
%     checkNumCol:    Number of right edge columns to check
%                     [in pixels] (Default: 3)
%
%     allowedDiff:    Allowable difference in RGB values to decide if close
%                     enough to background color (Default: 5)
%
%> Notes:
%     - "FFMPEG" (necessary for image manipulation, needs to be added
%       to PATH)
%     - Meant for Windows machines
%
%> Harrison Ross Hibbett (harrison_hibbett@alumni.brown.edu) 2026
arguments
    folderPath string
    expectedColor double = [255 255 255]
    checkNumCol double = 3
    allowedDiff double = 5
end

    files = listImageFiles(folderPath);

    for i = 1:length(files)

        colsToChange = rightColumnsColorCompare(files(i), checkNumCol, expectedColor, allowedDiff);

        stripW = colsToChange;
        colorHex = sprintf('0x%02X%02X%02X', expectedColor);
        tmpFile = '_tmp.jpg';

        if stripW > 0
            cmd = sprintf([ ...
                'ffmpeg -i "%s" ' ...
                '-vf "format=rgb24,drawbox=x=iw-%d:y=0:w=%d:h=ih:color=%s:t=fill" ' ...
                '-q:v 1 "%s" && move /Y "%s" "%s"' ], ...
                files(i), stripW, stripW, colorHex, tmpFile, tmpFile, files(i));
    
            system(cmd);
        end
    end

end

function colsToChange = rightColumnsColorCompare(imgPath,checkNumCol,expectedColor,allowedDiff)
    colColors = rightColCheck(imgPath, checkNumCol);
    colsToChange = compareColors(colColors, expectedColor, allowedDiff);
end


function colColors = rightColCheck(imgPath, checkNumCol)
    img = imread(imgPath);

    imgSize = size(img);
    height = imgSize(1);
    width = imgSize(2);

    colColors = zeros([checkNumCol, 3]);
    for i = 1:checkNumCol
        col_r = img(:,width-i+1,1);
        col_g = img(:,width-i+1,2);
        col_b = img(:,width-i+1,3);
        mean_r = mean(col_r);
        mean_g = mean(col_g);
        mean_b = mean(col_b);
        colorCol_i = [mean_r, mean_g, mean_b];
        colColors(i,:) = colorCol_i;
    end

end

function colsToChange = compareColors(colorsArray, expectedColor, allowedDiff)
    % expectedColor in RGB [0-255, 0-255, 0-255] format
    flag = 1;
    counter = 1;
    while flag == 1
        for colors = 1:3
            if abs(colorsArray(counter, colors) - expectedColor(colors)) > allowedDiff
                counter = counter + 1;
                break
            else
                if colors == 3
                    flag = 0;
                end
            end
        end
    end

    colsToChange = counter - 1;

end

function files = listImageFiles(folder)
    if nargin < 1 || ~isfolder(folder)
        error('Input must be a valid folder path.');
    end
    exts = {'*.jpg', '*.jpeg', '*.png', '*.tif', '*.tiff', '*.bmp', '*.webp' };
    files = strings(0);
    for k = 1:numel(exts)
        d = dir(fullfile(folder, exts{k}));
        for n = 1:numel(d)
            files(end+1) = fullfile(d(n).folder, d(n).name); 
        end
    end
    files = sort(files);   
end

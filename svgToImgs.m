function svgToImgs(nameOut,svgIn,storageType,widthOrHeight,pixelsDist)
%> Code Description:
%     Converts an input .svg file into .png and/or .jpg image files using
%     command line tools "rsvg-convert" and "magick" (required).
%
%> Inputs:
%     nameOut:                   Path for the saved output image file(s),
%                                without extension
%
%     svgIn:                     Full path to the input .svg file
%
%     storageType:               Output image type:
%                                   'b' -> both .png and .jpg (Default)
%                                   'j' -> .jpg only
%                                   'p' -> .png only
%
%     widthOrHeight:             Dimension to constrain during conversion:
%                                   'w' -> width (Default)
%                                   'h' -> height
%
%     pixelsDist:                Pixel value corresponding to the chosen
%                                width or height (Default: 512)
%
%> Notes:
%         - "rsvg-convert"  (for .svg -> .png)
%         - "magick"        (ImageMagick, for .png -> .jpg conversion)
%
%> Harrison Ross Hibbett (harrison_hibbett@alumni.brown.edu) 2025
    arguments
        nameOut string
        svgIn string
        storageType string = "b"
        widthOrHeight string = "w"
        pixelsDist double = 512
    end

    if storageType ~= "b" && storageType ~= "j" && storageType ~= "p"
        disp("Storage Type not accepted. Please use 'b', 'j', or 'p' for both, jpg, or png");
        return
    end
    if widthOrHeight ~= "w" && widthOrHeight ~= "h"
        disp("widthOrHeight Parameter not accepted. Please use 'w', or 'h'");
        return
    end

    % Create .png
    nameOut_png = nameOut + ".png";
    cmd = sprintf('rsvg-convert -%s %d "%s" -o "%s"',widthOrHeight, pixelsDist, svgIn, nameOut_png);
    system(cmd);

    if storageType == "b" % Both .jpg and .png
        % Create .jpg
        nameOut_jpg = nameOut + ".jpg";
        cmd = sprintf('magick "%s" "%s"', nameOut_png, nameOut_jpg);
        system(cmd);
    elseif storageType == "j" % Only .jpg --> convert from .png to .jpg, delete .png
        % Create .jpg
        nameOut_jpg = nameOut + ".jpg";
        cmd = sprintf('magick "%s" "%s"', nameOut_png, nameOut_jpg);
        system(cmd);
        % Delete .png
        cmd = sprintf('del "%s"', nameOut_png);
        system(cmd);
    end
end
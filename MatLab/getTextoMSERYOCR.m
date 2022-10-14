

function ocrtxt = getTextoMSERYOCR(IMat)

    %[aa bb]=uigetfile({'*.*','All files'});
    %IMat=imread([bb aa]);
    
    
    I = im2gray(IMat);
    
    % Detect MSER regions.
    [mserRegions, mserConnComp] = detectMSERFeatures(I, ... 
        'RegionAreaRange',[200 8000],'ThresholdDelta',4);
    
    % Use regionprops to measure MSER properties
    mserStats = regionprops(mserConnComp, 'BoundingBox', 'Eccentricity', ...
        'Solidity', 'Extent', 'Euler', 'Image');
    
    % Compute the aspect ratio using bounding box data.
    bbox = vertcat(mserStats.BoundingBox);
    w = bbox(:,3);
    h = bbox(:,4);
    aspectRatio = w./h;
    
    % Threshold the data to determine which regions to remove. These thresholds
    % may need to be tuned for other images.
    filterIdx = aspectRatio' > 3; 
    filterIdx = filterIdx | [mserStats.Eccentricity] > .995 ;
    filterIdx = filterIdx | [mserStats.Solidity] < .3;
    filterIdx = filterIdx | [mserStats.Extent] < 0.2 | [mserStats.Extent] > 0.9;
    filterIdx = filterIdx | [mserStats.EulerNumber] < -4;
    
    % Remove regions
    mserStats(filterIdx) = [];
    mserRegions(filterIdx) = [];
    
    % Get bounding boxes for all the regions
    bboxes = vertcat(mserStats.BoundingBox);
    
    % Convert from the [x y width height] bounding box format to the [xmin ymin
    % xmax ymax] format for convenience.
    xmin = bboxes(:,1);
    ymin = bboxes(:,2);
    xmax = xmin + bboxes(:,3) - 1;
    ymax = ymin + bboxes(:,4) - 1;
    
    % Expand the bounding boxes by a small amount.
    expansionAmount = 0.06;
    xmin = (1-expansionAmount) * xmin;
    ymin = (1-expansionAmount) * ymin;
    xmax = (1+expansionAmount) * xmax;
    ymax = (1+expansionAmount) * ymax;
    
    % Clip the bounding boxes to be within the image bounds
    xmin = max(xmin, 1);
    ymin = max(ymin, 1);
    xmax = min(xmax, size(I,2));
    ymax = min(ymax, size(I,1));
    
    % Show the expanded bounding boxes
    expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
    
    % Compute the overlap ratio
    overlapRatio = bboxOverlapRatio(expandedBBoxes, expandedBBoxes);
    
    % Set the overlap ratio between a bounding box and itself to zero to
    % simplify the graph representation.
    n = size(overlapRatio,1); 
    overlapRatio(1:n+1:n^2) = 0;
    
    % Create the graph
    g = graph(overlapRatio);
    
    % Find the connected text regions within the graph
    componentIndices = conncomp(g);
    
    % Merge the boxes based on the minimum and maximum dimensions.
    xmin = accumarray(componentIndices', xmin, [], @min);
    ymin = accumarray(componentIndices', ymin, [], @min);
    xmax = accumarray(componentIndices', xmax, [], @max);
    ymax = accumarray(componentIndices', ymax, [], @max);
    
    
    %------------------
    % Reducimos los bounding boxes un poco ahora que están unidos.
    expansionAmount = 0.04;
    xmin = (1+expansionAmount) * xmin;
    ymin = (1+expansionAmount) * ymin;
    xmax = (1-expansionAmount) * xmax;
    ymax = (1-expansionAmount) * ymax;
    
    % Clip the bounding boxes to be within the image bounds
    xmin = max(xmin, 1);
    ymin = max(ymin, 1);
    xmax = min(xmax, size(I,2));
    ymax = min(ymax, size(I,1));
    
    %------------
    
    
    % Compose the merged bounding boxes using the [x y width height] format.
    textBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
    
    % Remove bounding boxes that only contain one text region
    numRegionsInGroup = histcounts(componentIndices);
    textBBoxes(numRegionsInGroup == 1, :) = [];
    
    % Show the final text detection result.
    ITextRegion = insertShape(IMat, 'rectangle', textBBoxes,'LineWidth',3);
    
    figure
    imshow(ITextRegion)
    title('Detected Text')
    
    
    
    ocrtxt = ocr(I, textBBoxes, 'CharacterSet','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ','TextLayout','Block');
    %disp([ocrtxt.Text]);

end
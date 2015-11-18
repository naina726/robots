function hw4_team21(textfile)
    % takes in textfile that was output by
    % dijkstra's algorithm in python
    % "shortestpath.txt"
    
    % opens the file to read
    fid = fopen(textfile);
    
    % reads in the start point
    tline = fget1(fid);
    x = float(point(0));
    y = float(point(1));
    
    % while there are nodes to be travelled to
    while ischar(tline)
        % read the point
        point = strsplit(tline);
        % change the offset
        x = float(point(0)) - x;
        y = float(point(1)) - y;
        % calculate angle to be turned
        theta = atan(y/x);
        % calculate distance to be travelled
        d = sqrt(y^2 + x^2);
        % turn the angle
        turnAngle(90-theta);
        % travel the distance
        travelDist(d);
        % turn back to original angle
        turnAngle(-(90-theta))
        % read next line
        tline = fget1(fid);
    end
    % close the file
    fclose(fid);
end
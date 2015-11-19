function hw4_team21(serPort);
    % takes in textfile that was output by
    % dijkstra's algorithm in python
    % "shortestpath.txt"

    % opens the file to read
    fid = fopen('shortestPath.txt');
    tmp = fscanf(fid,'%f');
    fclose(fid);
    % reads in the start point
    x = tmp(1);
    y = tmp(2);
    
    % while there are nodes to be travelled to
    for i=3:2:length(tmp)
        % read the point
        %temp = strsplit(tmp)
        % change the offset
        x = tmp(i) - x;
        y = tmp(i+1) - y;
        % calculate angle to be turned
        theta = atan(y/x);
        % calculate distance to be travelled
        d = sqrt(y^2 + x^2);
        % turn the angle
        turnAngle(serPort,0.1,90-theta);
        % travel the distance
        travelDist(serPort,0.4,d);
        % turn back to original angle
        turnAngle(serPort,0.1,-(90-theta));
    end
end
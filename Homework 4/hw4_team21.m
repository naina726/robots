function hw4_team21(textfile, start_x, start_y)
    fid = fopen(textfile);
    x = start_x;
    y = start_y;
    
    tline = fget1(fid);
    while ischar(tline)
        point = strsplit(tline);
        x = float(point(0)) - x;
        y = float(point(1)) - y;
        theta = atan(y/x);
        d = sqrt(y^2 + x^2);
        turnAngle(90-theta);
        travelDist(d);
        turnAngle(-(90-theta))
        tline = fget1(fid);
    end
    fclose(fid);
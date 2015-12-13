

function [] = hw5PartII(serPort);
% knockDoor(serPort)
% return

% 0 represents left, 1 represents right
direction = -1;
while direction == -1
    travelDist(serPort, 0.1, 0.2);
    pause(0.5)
    image = imread('http://192.168.0.101/img/snapshot.cgi?');
    imshow(image)
    [m,n, a] = size(image);
    pichsv = rgb2hsv(image);

    column_count = 0;
    for j= 1:m
        if pichsv(j,1,1) > 0.56 && pichsv(j,1,1) < 0.675
            column_count = column_count + 1;
        end
    end
    if column_count > m / 2
        if direction == -1
            direction = 0;
            disp('found left');
            disp(['left is ' num2str(column_count)]);
        end

    end

    column_count = 0;
    for j= 1:m
        if pichsv(j,320,1) > 0.56 && pichsv(j,320,1) < 0.675
            column_count = column_count + 1;
        end
    end
    if column_count > m / 2
        if direction == -1
            direction = 1;
            disp('found right');
            disp(['right is ' num2str(column_count)]);
        end

    end
end

while 1
    travelDist(serPort, 0.1, 0.2);
    pause(0.5)
    image = imread('http://192.168.0.101/img/snapshot.cgi?');
    imshow(image)
    [m,n, a] = size(image);
    pichsv = rgb2hsv(image);
    if direction == 0
        column_count = 0;
        for j= 1:m
            if pichsv(j,1,1) > 0.56 && pichsv(j,1,1) < 0.675
                column_count = column_count + 1;
            end
        end
        disp('wait left to disappear')
        disp(['left col ' num2str(column_count)])
        if column_count < m / 10
            break
        end
    else

        column_count = 0;
        for j= 1:m
            if pichsv(j,320,1) > 0.56 && pichsv(j,320,1) < 0.675
                column_count = column_count + 1;
            end
        end
        disp('wait right to disappear')
        disp(['right col ' num2str(column_count)])

        if column_count < m / 10
            %direction = 1;
            break
        end
        
    end
end
travelDist(serPort, 0.1, 0.5);
pause(0.5);




BumpRight = 0;
BumpLeft  = 0;
BumpFront = 0;
properAngle = findProperAngle(serPort, direction);
disp(['the proper angle is ' num2str(properAngle)]);
turnAngle(serPort, 0.05, properAngle);
while BumpRight == 0 && BumpLeft == 0 && BumpFront == 0
     SetFwdVelRadiusRoomba(serPort, 0.2, inf);
     pause(0.5)
    [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    % disp(['new sensor is ' num2str(BumpLeft) num2str(BumpFront) num2str(BumpLeft)])
end 


SetFwdVelRadiusRoomba(serPort, 0, inf);
pause(0.5)
knockDoor(serPort);

end


function properAngle = findProperAngle(serPort, direction);
    % choose from 25, 30, 35
    % choose from 40, 50, 60
    if direction == 0
        turnAngle(serPort, 0.05, 40);
        image = imread('http://192.168.0.101/img/snapshot.cgi?');
        pichsv = rgb2hsv(image);
        width1 = calculateWidth(pichsv, direction);

        turnAngle(serPort, 0.05, 10);
        image = imread('http://192.168.0.101/img/snapshot.cgi?');
        pichsv = rgb2hsv(image);
        width2 = calculateWidth(pichsv, direction);

        turnAngle(serPort, 0.05, 10);
        image = imread('http://192.168.0.101/img/snapshot.cgi?');
        pichsv = rgb2hsv(image);
        width3 = calculateWidth(pichsv, direction);
        disp(['three width are' num2str(width1) num2str(width2) num2str(width3)])
        if width1 >= width2 && width1 >= width3
            properAngle = -20;
            return
        end

        if width2 >= width1 && width2 >= width3
            properAngle = -10;
            return
        end

        if width3 >= width1 && width3 >= width2
            properAngle = 0;
            return
        end


    else  % right
        turnAngle(serPort, 0.05, -40);
        image = imread('http://192.168.0.101/img/snapshot.cgi?');
        pichsv = rgb2hsv(image);
        width1 = calculateWidth(pichsv, direction);

        turnAngle(serPort, 0.05, -10);
        image = imread('http://192.168.0.101/img/snapshot.cgi?');
        pichsv = rgb2hsv(image);
        width2 = calculateWidth(pichsv, direction);

        turnAngle(serPort, 0.05, -10);
        image = imread('http://192.168.0.101/img/snapshot.cgi?');
        pichsv = rgb2hsv(image);
        width3 = calculateWidth(pichsv, direction);

        if width1 >= width2 && width1 >= width3
            properAngle = -20;
            return
        end

        if width2 >= width1 && width2 >= width3
            properAngle = -10;
            return
        end

        if width3 >= width1 && width3 >= width2
            properAngle = 0;
            return
        end

    end

end


function currentWidth = calculateWidth(pichsv, direction);
    [m,n, a] = size(pichsv);
    currentWidth = 0;
    % imshow(pichsv)
    if direction == 0
        startCol = 0;
        for i = 1:n
            column_count = 0;
            for j = 1:m
                if pichsv(j,i,1) > 0.56 && pichsv(j,i,1) < 0.675
                    column_count = column_count + 1;
                end
            end
            if column_count > m / 2
                if startCol == 0
                    startCol = i;
                end
            %end   
            else
                if startCol ~= 0
                    currentWidth = i - startCol; 
                    return
                end
            end
        end

    else  % direction = 1
        startCol = 0;
        for k = 1:n
            i = n - k + 1;
            column_count = 0;
            for j = 1:m
                if pichsv(j,i,1) > 0.56 && pichsv(j,i,1) < 0.675
                    column_count = column_count + 1;
                end
            end
            if column_count > m / 2
                if startCol == 0
                    startCol = i;
                    disp(['start col is' num2str(startCol)])
                end
            end
            %end   
            if column_count < m / 10
            %if column_count < m / 10
                if startCol ~= 0
                    currentWidth = startCol - i;
                    disp(['current no right is ' num2str(i) ' and column_count is ' num2str(column_count)])
                    return
                end
            end
        end


    end
end







function [] = knockDoor(serPort);

% knock on the door
% assuming Robot is already facing the door

% move robot away from door
travelDist(serPort, 0.3, -.1);
pause(1);

% read the sensors to set initial values
% [BR, BL, BF, W, virtWall, CliffLft, ...
%     CliffRgt, CliffFrntLft, CliffFrntRgt, LeftCurrOver, RightCurrOver, ...
%     DirtL, DirtR, ButtonPlay, ButtonAdv, Dist, Angle, ...
%     Volts, Current, Temp, Charge, Capacity, pCharge] = AllSensorsReadRoomba(serPort);
[BR,BL,a,b,c,BF] = BumpsWheelDropsSensorsRoomba(serPort);

% First Knock
% while we havent hit the door
while(BR==0 && BF==0 && BF==0)
    
    % move forward
     SetFwdVelRadiusRoomba(serPort, 0.2, inf);

    pause(1);
    % rea sensors again
    [BR,BL,a,b,c,BF] = BumpsWheelDropsSensorsRoomba(serPort);

end

% move away from door again
travelDist(serPort, 0.3, -.1);

% read sensors again
[BR,BL,a,b,c,BF] = BumpsWheelDropsSensorsRoomba(serPort);

% while we havent hit the door again
while(BR==0 && BF==0 && BF==0)
    % move forward towards door
     SetFwdVelRadiusRoomba(serPort, 0.2, inf);

    pause(1);
    
    % read sensors again
    [BR,BL,a,b,c,BF] = BumpsWheelDropsSensorsRoomba(serPort);

end
SetFwdVelRadiusRoomba(serPort, 0, inf);


% emit beep
BeepRoomba(serPort);

% pause for door to open
%pause(5);

% navigate through door
%travelDist(serPort, 0.3, 0.1);

end

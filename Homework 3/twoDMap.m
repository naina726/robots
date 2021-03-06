% For this program, we don't judge whether one point is inside a obstacle or not. we just marked these points as 
% unmarked

function twoDMap(serPort)
    global currentX currentY maxVel currentAngle positionMatrix fig
    global diameter
    global notUpdatedTimes
    diameter = 0.3;
    notUpdatedTimes = 0;
    maxVel = 0.2;
    currentX = 0;
    currentY = 0; 
    currentAngle = AngleSensorRoomba(serPort);
    currentAngle = AngleSensorRoomba(serPort);
    DistanceSensorRoomba(serPort);
    DistanceSensorRoomba(serPort);
    initializeMatrix();

    %firstTime = 1;

    %goRandom(serPort);
    goStraight(serPort);
    while(notUpdatedTimes < 120)
        % if firstTime == 1
        %     disp('start go random');
        %     goRandom(serPort);
        %     disp('end go random')
        %     firstTime = 0;

        % else
        if isObstacle(currentX, currentY)
            disp('already been here')
            goRandom(serPort);
            resultMatrix = dispMatrix();
            drawMap(resultMatrix);
            disp(['not update times is ' num2str(notUpdatedTimes)])
            continue
        end
        %end

        followTheBound(serPort, currentX, currentY)
        %SetFwdVelRadiusRoomba(serPort, 0, inf)
        pause(1)
        resultMatrix = dispMatrix();
        drawMap(resultMatrix);
        disp(['not update times is ' num2str(notUpdatedTimes)])            


    end
    %resultMatrix = dispMatrix();
    %drawMap(resultMatrix);




end

function initializeMatrix()
    global positionMatrix;
    positionMatrix(1:50, 1:50) = -1;
end

function isObstacle = isObstacle(currentX, currentY)
    global positionMatrix;
    [roundX, roundY] = transCoordinate(currentX, currentY);
    disp(['in isObstacle, the currentpoint result is ' num2str(positionMatrix(roundX, roundY))]);
    disp(['currentX is ' num2str(currentX) ' currentY is ' num2str(currentY) ' roundX is '...
            num2str(roundX) ' roundY is ' num2str(roundY) ' positionMatrix is ' ...
            num2str(positionMatrix(roundX, roundY))]);
    if positionMatrix(roundX, roundY) == 1
        isObstacle = true;
    else
        isObstacle = false;
    end
end


function aroundObstacleNum = AroundObstacle(currentX, currentY)
    global positionMatrix
    aroundObstacleNum = false;
    % [roundX, roundY] = transCoordinate(currentX, currentY);
    %  positionMatrix(roundX, roundY) == 1 || positionMatrix(roundX-1, roundY) == 1 || ...
    %     positionMatrix(roundX+1, roundY) == 1 || positionMatrix(roundX, roundY-1) == 1 || ...
    %     positionMatrix(roundX, roundY+1) == 1
    %     aroundObstacle = true;
    % else
    %     aroundObstacle = false;
    % end

end



function [matrixPositionX, matrixPositionY] = transCoordinate(inputX, inputY)
    matrixPositionX = round(inputX / 0.3) + 20;
    matrixPositionY = round(inputY / 0.3) + 20;
end


function followTheBound(serPort, startX, startY)
  global currentAngle currentX currentY notUpdatedTimes
  disp(['the startX is ' num2str(startX) ' and startY is ' num2str(startY)])
    max_vel = 0.2;
   [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
   [Wall]= WallSensorReadRoomba(serPort);
    
    % The main while loop
    %startMoving = 0;
    %hasStraight = 0;
    %startStraight = 0;
    whileLoopIndicaters = 0;
    obstacleNum = 0;
    while (1)

       while ((BumpRight==0 && BumpLeft==0 && BumpFront == 0 && Wall == 1))
            SetFwdVelRadiusRoomba(serPort, max_vel, inf);
            pause(0.1);
            [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            [Wall]= WallSensorReadRoomba(serPort);   
            magnitude = DistanceSensorRoomba(serPort);
            currentX = currentX + magnitude * cos(currentAngle);
            currentY = currentY + magnitude * sin(currentAngle);
            % if AroundObstacle(currentX, currentY)
            %     obstacleNum = obstacleNum + 1;
            % else
            %     obstacleNum = 0;
            % end
            updateMatrix(currentX, currentY, 1)
            %hasStraight = 1;


            % disp(['CURRENTX' num2str(currentX)]);
            disp(['1 startX is ' num2str(startX) ' and currentX is ' num2str(currentX)])
            disp(['1 startY is ' num2str(startY) ' and currentY is ' num2str(currentY)])
            if (IsEquivalent(currentY, startY) && whileLoopIndicaters > 5 && IsEquivalent(currentX, startX))
                break
            end
       end
       if IsEquivalent(currentY, startY) && whileLoopIndicaters > 5 && IsEquivalent(currentX, startX)
          disp(['reached start point 1']);
            SetFwdVelRadiusRoomba(serPort, 0, inf);

          return
       end

       % This means that the wall has been followed before
       % disp(['obstacleNum is ' num2str(obstacleNum)])
       % if obstacleNum > 100
       %  return
       % end
        disp(['1 in followbound , not update is ' num2str(notUpdatedTimes)])
       if notUpdatedTimes > 60
            return
        end
%        if hasStraight == 1
%             startStraight = 1;
%        end


        while(BumpRight==1 || BumpLeft==1 || BumpFront == 1)
            turnAngle(serPort, 0.2, 5);
            updateMatrix(currentX, currentY, 1)
            disp(['turning left']);
            [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
        end
        
        currentAngle = currentAngle + AngleSensorRoomba(serPort);

        while (Wall == 0 && (BumpRight==0 || BumpLeft==0 || BumpFront==0 ))
            disp(['no wall detected']);
            % Turn little left and then go little further.
            turnAngle(serPort, 0.2, -5);
            travelDist(serPort, 0.05, 0.01);
            [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            [Wall]= WallSensorReadRoomba(serPort);
            currentAngle = currentAngle + AngleSensorRoomba(serPort);
            magnitude = DistanceSensorRoomba(serPort);
            currentX = currentX + magnitude * cos(currentAngle);
            currentY = currentY + magnitude * sin(currentAngle);
            
            % if AroundObstacle(currentX, currentY)
            %     obstacleNum = obstacleNum + 1;
            % else
            %     obstacleNum = 0;
            % end
            
            updateMatrix(currentX, currentY, 1)
            
            disp(['startX is ' num2str(startX) ' and currentX is ' num2str(currentX)])
            disp(['startY is ' num2str(startY) ' and currentY is ' num2str(currentY)])

            disp(['the magnitude is ' num2str(magnitude) ' and the angle is '  num2str(currentAngle)])

            if IsEquivalent(currentY, startY) && whileLoopIndicaters > 5 && IsEquivalent(currentX, startX)
                return
            end
        end
        
       if IsEquivalent(currentY, startY) && whileLoopIndicaters > 5 && IsEquivalent(currentX, startX)
            disp(['reached start point 2']);
            SetFwdVelRadiusRoomba(serPort, 0, inf);

            return
       end

       % disp(['obstacleNum is ' num2str(obstacleNum)])
       % if obstacleNum > 100
       %      return
       % end

        disp(['2 in followbound , not update is ' num2str(notUpdatedTimes)])
       if notUpdatedTimes > 60
            return
        end
       whileLoopIndicaters = whileLoopIndicaters + 1;

       %startMoving = 1;
       disp(['in followTheBound, the whileLoopIndicaters is ' num2str(whileLoopIndicaters)])

    end
end

function updateMatrix(currentX, currentY, status)
    global positionMatrix notUpdatedTimes
    [roundX, roundY] = transCoordinate(currentX, currentY);
    if positionMatrix(roundX, roundY) == status
        notUpdatedTimes = notUpdatedTimes + 1;
    else
        notUpdatedTimes = 0;
    end
    positionMatrix(roundX, roundY) = status;

end


function goRandom(serPort)
    global currentAngle
    [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    [Wall]= WallSensorReadRoomba(serPort);
    randomAngle = 0;
    if BumpRight == 1 || Wall == 1
        randomAngle = round(120 * rand + 30);
    elseif BumpFront == 1
        randomAngle = round(120 * rand + 120);
    elseif BumpLeft == 1
        randomAngle = 0 - round(120 * rand + 30);
    else
        randomAngle = round(360 * rand);
    end

    %randomAngle = round(45 * rand);
    turnAngle(serPort, 0.2, randomAngle);
    currentAngle = currentAngle + AngleSensorRoomba(serPort);
    goStraight(serPort);
end

function goStraight(serPort)
    global currentX currentY currentAngle maxVel
    maxVel = 0.2;
   [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
  
   
   while (BumpRight==0 && BumpLeft==0 && BumpFront == 0)
        [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
        SetFwdVelRadiusRoomba(serPort, maxVel, inf);
        pause(0.1)
        magnitude = DistanceSensorRoomba(serPort);
        currentX = currentX + magnitude * cos(currentAngle);
        currentY = currentY + magnitude * sin(currentAngle);
        if ~isObstacle(currentX, currentY)
            updateMatrix(currentX, currentY, 0)
        end
    end
end


function isEquivalent = IsEquivalent(x,y)
    isEquivalent =  abs(x-y) < 0.15;
end



function resultMatrix = dispMatrix()
    global positionMatrix
    leftBound = 101;
    rightBound = -1;
    upBound = -1;
    lowBound = 101;
    for i = 1:50
        for j = 1:50
            if positionMatrix(i,j) ~= -1
                if j < leftBound
                    leftBound = j;
                end
                if j > rightBound
                    rightBound = j;
                end
                if i < lowBound
                    lowBound = i;
                end
                if i > upBound
                    upBound = i;
                end
            end
        end
    end
    disp(['bound is ' num2str(leftBound) ' ' num2str(upBound) ' ' num2str(rightBound) ' ' num2str(lowBound)]);
    disp(positionMatrix(lowBound:upBound, leftBound:rightBound));
    resultMatrix = positionMatrix(lowBound:upBound, leftBound:rightBound);

end


function drawMap(resultMatrix)
    [r,c] = size(resultMatrix);
    figure
    imagesc((1:c)+0.5,(1:r)+0.5, resultMatrix);
end
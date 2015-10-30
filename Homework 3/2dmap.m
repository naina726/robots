% For this program, we don't judge whether one point is inside a obstacle or not. we just marked these points as 
% unmarked

function twoDMap(serPort)
    global currentX currentY maxVel currentAngle
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
    goRandom(serPort);
    %goStraight(serPort)
        %go_random()
%         
    while(notUpdatedTimes < 120)
        if IsExplored(currentX, currentY)
            goRandom(serPort);
            continue
        end
        followTheBound(serPort, currentX, currentY)
    end
    %drawMap()



end

function initializeMatrix()
    global positionMatrix;
    positionMatrix(1:100, 1:100) = -1;
end

function isExplored = IsExplored(currentX, currentY)
    global positionMatrix;
    [roundX, roundY] = transCoordinate(currentX, currentY);
    
    % bug test
    isExplored = false;
    return
    
    if positionMatrix(roundX, roundY) ~= -1
        isExplored = true;
    else
        isExplored = false;
    end
end



function [matrixPositionX, matrixPositionY] = transCoordinate(inputX, inputY)
    matrixPositionX = round(inputX / 0.3);
    matrixPositionY = round(inputY / 0.3);
end


function followTheBound(serPort, startX, startY)
  global currentAngle currentX currentY
    max_vel = 0.2;
   [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
   [Wall]= WallSensorReadRoomba(serPort);
    
    % The main while loop
    startMoving = 0;
    while (1)
       while ((BumpRight==0 && BumpLeft==0 && BumpFront == 0 && Wall == 1))
            SetFwdVelRadiusRoomba(serPort, max_vel, inf);
            pause(0.1);
            [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            [Wall]= WallSensorReadRoomba(serPort);   
            magnitude = DistanceSensorRoomba(serPort);
            currentX = currentX + magnitude * cos(currentAngle);
            currentY = currentY + magnitude * sin(currentAngle);
            
            updateMatrix(currentX, currentY, 1)

            % disp(['CURRENTX' num2str(currentX)]);
            disp('go straight forward in followTheBound')
            disp(['the currentY is ' num2str(currentY)])
            if (IsEquivalent(currentY, startY) && startMoving == 1 && IsEquivalent(currentX, startX))
                break
            end
       end
       if IsEquivalent(currentY, startY) && startMoving == 1 && IsEquivalent(currentX, startX)
          disp(['jump out of funciton followTheBoud']);
          return
       end


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
            
            updateMatrix(currentX, currentY, 1)
            
            disp(['the magnitude is ' num2str(magnitude) ' and the angle is '  num2str(currentAngle)])

            if IsEquivalent(currentY, startY) && startMoving == 1 && IsEquivalent(currentX, startX)
                return
            end
        end
        
       if IsEquivalent(currentY, startY) && startMoving == 1 && IsEquivalent(currentX, startX)
            return
       end

       startMoving = 1;

    end
end

function updateMatrix(currentX, currentY, status)
    global positionMatrix notUpdatedTimes
    [roundX, roundY] = transCoordinate(currentX, currentY);
    disp([num2str(roundX) ' ' num2str(roundY)])
    return
    if positionMatrix(roundX, roundY) ~= -1
        notUpdatedTimes = notUpdatedTimes + 1;
    else
        positionMatrix(roundX, roundY) = status;
        notUpdatedTimes = 0;
    end
end


function goRandom(serPort)
    randomAngle = round(360 * rand - 180);
    turnAngle(serPort, 0.2, randomAngle);
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
        updateMatrix(currentX, currentY, 0)
    end
end


function isEquivalent = IsEquivalent(x,y)
    isEquivalent =  abs(x-y) < 0.05;
end



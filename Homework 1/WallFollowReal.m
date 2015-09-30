%**********************************************
% Jasleen Nuno (jn2465)
% Naina Prasad (np2302)
% Yiqing Cui (yc3121)
% Team 21
% Homework 1
%**********************************************

function WallFollowReal(serPort)
   % Set the max Velocity 
   max_vel = 0.4;
   
   [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
   [Wall]= WallSensorReadRoomba(serPort);
   disp(['zero' num2str(BumpRight) num2str(BumpLeft) num2str(BumpFront) num2str(Wall)])

    % Move EVE forward until she hits a wall
    while (BumpRight==0 && BumpLeft==0 && BumpFront == 0)
         SetFwdVelRadiusRoomba(serPort, 0.05, inf);
         pause(0.1);
         [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    end
    pause(0.1);
    
    disp(['zero2' num2str(BumpRight) num2str(BumpLeft) num2str(BumpFront) num2str(Wall)])

        
   % To keep track of position         
    initialX = 0;
    initialY = 0;
    currentX = 0;
    currentY = 0;
    
    angle = AngleSensorRoomba(serPort);
    DistanceSensorRoomba(serPort);

    % To record that whether the robot has returned to the start point
    returnToStart = 0;
    
    % The main while loop
    while (1)
       
       % The I part: Go straight forward. 
       % Before this loop, we have to record the original isStartPoint. 
       % This is to deal with the problem
       % that sometimes the robot stops at the start point at the
       % beginning, without going anywhere. We Assume that the robot will
       % return to the start point only in the middle of I or III part.
       beforeLoopIsStartPoint = IsStartPoint(currentX, currentY, initialX, initialY);
       turnRightTimes = 0
       while (BumpRight==0 && BumpLeft==0 && BumpFront == 0)
            % Turn little right and then go little further.
            turnRightTimes = turnRightTimes+1
            travelDist(serPort, 0.1, 0.1);
            angle = angle + AngleSensorRoomba(serPort);

            [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            if (BumpRight == 1 || BumpLeft == 1 || BumpFront == 1)
                break;
            end
            turnAngle(serPort, 0.05, -1*(turnRightTimes+1));
            magnitude = DistanceSensorRoomba(serPort);
            currentX = currentX + magnitude * cos(angle);
            currentY = currentY + magnitude * sin(angle);
            
            % If the robot returns to the start point in this loop, then
            % set returnToStart to 1 and break out of the main
            % loop. Program ends.
            if (beforeLoopIsStartPoint == 0 ...
                && IsStartPoint(currentX, currentY, initialX, initialY) == 1)
                returnToStart = 1;
                break
            end
       end
       
       disp(['first' num2str(BumpRight) num2str(BumpLeft) num2str(BumpFront) num2str(Wall)])

       if(returnToStart == 1)
           break
       end
       

        % The II Part: Turn left until there is no bump detected.
        % Note that in this part, the robot didn't go any further, so
        % there is no way that the robot returns to the start point after
        % this Part.
        while(BumpRight==1 || BumpLeft==1 || BumpFront == 1)
            turnAngle(serPort, 0.05, 2);
            [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
        end
        disp(['second' num2str(BumpRight) num2str(BumpLeft) num2str(BumpFront) num2str(Wall)])

        
        angle = angle + AngleSensorRoomba(serPort);
        
       

    end
    

end

% To test whether the current point is close enouth to the start point
function isStartPoint = IsStartPoint(currentX, currentY, initialX, initialY)
    isStartPoint ...
        = (currentX - initialX)^2 + (currentY - initialY)^2 < 0.05;
end
  
 

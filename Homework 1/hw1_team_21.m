%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMS W4733 Computational Aspects of Robotics 2015
%
% Homework 1
%
% Team number: 21
% Team leader: Yiqing Cui(yc3121)
% Team members: Jasleen Nuno (jn2465)  Naina Prasad (np2302)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problems with this project.
% After several trials on our Create robot, we found that there are at least 3 problems:
% 1. The BumpFront Sensor is not correct. In most cases, when the program starts, 
%   the BumpFront is 1 even there is nothing in front of the robot.
% 2. The wall sensor is almost useless. No matter how I change the angle between 
%   the robot and the wall, the wall sensor is always 0.
% 3. We can’t run demo on robots.
% Therefore, we don't use wall sensor at all when the code is executed on Create. 
% In that case, the robot may run in a very low velocity.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function hw1_team_21(serPort)
   % Set the max Velocity 
   p = properties(serPort);
    if size(p,1) == 0
    
      % running in the simulator
      runInSimulator(serPort)
    else
        
      % running on Create
      runInCreate(serPort)
    end

end


function runInSimulator(serPort)
   max_vel = 0.4;
   
   [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
   [Wall]= WallSensorReadRoomba(serPort);

    % Move EVE forward until she hits a wall
    while (BumpRight==0 && BumpLeft==0 && BumpFront == 0)
         SetFwdVelRadiusRoomba(serPort, max_vel, inf);
         pause(0.1);
         [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    end
    pause(0.1);
    
        
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
       while (BumpRight==0 && BumpLeft==0 && BumpFront == 0 && Wall == 1)
              SetFwdVelRadiusRoomba(serPort, max_vel, inf);
             pause(0.1);
              [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
               [Wall]= WallSensorReadRoomba(serPort);   
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
       if(returnToStart == 1)
           break
       end

        % The II Part: Turn left until there is no bump detected.
        % Note that in this part, the robot didn't go any further, so
        % there is no way that the robot returns to the start point after
        % this Part.
        while(BumpRight==1 || BumpLeft==1 || BumpFront == 1)
            turnAngle(serPort, 0.2, 5);
            [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
        end
        
        angle = angle + AngleSensorRoomba(serPort);
        
        % The III Part: To find the wall.
        % Since the robot has to walk along the wall, so when the wall
        % sensor is 0, it has to find the wall. 
        beforeLoopIsStartPoint = IsStartPoint(currentX, currentY, initialX, initialY);
        while (Wall == 0 && (BumpRight==0 || BumpLeft==0 || BumpFront==0 ))
            
            % Turn little left and then go little further.
            turnAngle(serPort, 0.2, -5);
            travelDist(serPort, 0.05, 0.01);
            [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            [Wall]= WallSensorReadRoomba(serPort);
            angle = angle + AngleSensorRoomba(serPort);
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
       if(returnToStart == 1)
           break
       end
    end
    

end


function runInCreate(serPort)

   [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
   [Wall]= WallSensorReadRoomba(serPort);
   disp(['zero' num2str(BumpRight) num2str(BumpLeft) num2str(BumpFront) num2str(Wall)])

    % Move EVE forward until she hits a wall
    while (BumpRight==0 && BumpLeft==0 && BumpFront == 0)
         SetFwdVelRadiusRoomba(serPort, 0.05, inf);
         %pause(0.1);
         [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    end
    %pause(0.1);
    
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
            
            %[BumpRight, BumpLeft, BumpFront, magnitude] = goFurther(serPort)
            SetFwdVelRadiusRoomba(serPort, 0.1, inf);
            SetFwdVelRadiusRoomba(serPort, 0, inf);
            magnitude = DistanceSensorRoomba(serPort);

            [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);

            currentX = currentX + magnitude * cos(angle);
            currentY = currentY + magnitude * sin(angle);
            %magnitude = DistanceSensorRoomba(serPort);

            %[BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            if (BumpRight==1 || BumpLeft==1 || BumpFront == 1)
                break;
            end
            turnAngle(serPort, min(0.05+0.02*turnRightTimes, 0.2), -0.6*(turnRightTimes));
            turningAngle = AngleSensorRoomba(serPort);
            angle = angle + turningAngle
            disp(['turning angle is ' num2str(turningAngle)])


            
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
        = (currentX - initialX)^2 + (currentY - initialY)^2 < 0.02;
end

function hw2_team_21(serPort)
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
    global angle currentX currentY
    angle = AngleSensorRoomba(serPort);
    angle = AngleSensorRoomba(serPort);
    DistanceSensorRoomba(serPort);
    [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    [Wall]= WallSensorReadRoomba(serPort);
    
    currentX = 0;
    currentY = 0;  
    max_vel = 0.2;
    while 1
        turningAngle = -angle/pi*180
        disp(['in main while loop, the angle is ' num2str(turningAngle)])
        pause(1)
        turnAngle(serPort, 0.2, turningAngle)
        angle = angle + AngleSensorRoomba(serPort);
        pause(1)
        disp(['turning back to the original angle'])
        [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);

        % while the robot is not at the target point and it doesn't hit any
        % wall, go straight forward.
        while ((~IsEquivalent(currentX, 4)|| ~TargetY(currentY)) && (BumpRight == 0 && BumpLeft == 0 && BumpFront == 0))
            SetFwdVelRadiusRoomba(serPort, max_vel, inf);
            pause(0.1);
            magnitude = DistanceSensorRoomba(serPort);
            currentX = currentX + magnitude * cos(angle);
            currentY = currentY + magnitude * sin(angle);
            [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            lastX = currentX;
        end

        % if the robot is at target point, stops the program
        if (TargetY(currentY) && IsEquivalent(currentX, 4))
            disp('Robot has reached the target point');
            SetFwdVelRadiusRoomba(serPort, 0, inf);
            return
        end

        while ((~IsEquivalent(currentX, 4) || ~TargetY(currentY)) && (~IsEquivalent(currentY, 0) || lastX - currentX >= 0 || currentX > 4.1))
            inputX = currentX
            followTheBound(serPort, inputX);
            if (TargetY(currentY) && IsEquivalent(currentX, lastX))
                disp(['the robot is trapped']);
                SetFwdVelRadiusRoomba(serPort, 0, inf);
                return
            end

            disp([currentX, currentY, angle]);
        end

        if (TargetY(currentY) && IsEquivalent(currentX, 4))
            SetFwdVelRadiusRoomba(serPort, 0, inf);
            disp(['Done']);
            return
        end

    end
end



function runInCreate(serPort) 
    global angle currentX currentY
    angle = AngleSensorRoomba(serPort);
    angle = AngleSensorRoomba(serPort);
    DistanceSensorRoomba(serPort);
    [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    [Wall]= WallSensorReadRoomba(serPort);
    
    currentX = 0;
    currentY = 0;  
    max_vel = 0.2;
    lastX = 0 
    
    while 1
        turningAngle = -angle/pi*180
        turnAngle(serPort, 0.2, turningAngle)
        angle = angle + AngleSensorRoomba(serPort);
        [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);

        % while the robot is not at the target point and it doesn't hit any
        % wall, go straight forward.
        disp(['after turning, the currentX is ' num2str(currentX) ' the currentY is ' num2str(currentY)])
        while ((~IsEquivalentReal(currentX, 4)|| ~TargetYReal(currentY)) && (BumpRight == 0 && BumpLeft == 0 && BumpFront == 0))
            SetFwdVelRadiusRoomba(serPort, max_vel, inf);
            pause(0.1);
            magnitude = DistanceSensorRoomba(serPort);
            currentX = currentX + magnitude * cos(angle);
            currentY = currentY + magnitude * sin(angle);
            disp('in main while loop, go towards the target')
            disp(['current X is ' num2str(currentX) ' and currentY is ' num2str(currentY)]);
            [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            lastX = currentX;
        end
        disp(['CHECKPOINT 1']);

        % if the robot is at target point, stops the program
        if (TargetYReal(currentY) && IsEquivalentReal(currentX, 4))
            disp('Robot has reached the target point');
            SetFwdVelRadiusRoomba(serPort, 0, inf);
            return
        end

        while ((~IsEquivalentReal(currentX, 4) || ~TargetYReal(currentY)) && (~IsEquivalentReal(currentY, 0) || lastX - currentX >= 0 || currentX > 4.1)) 
            disp(['start execute followTheBound'])
            inputX = currentX
            followTheBoundReal(serPort, inputX);
            disp(['after follow the bound the lastX is ' num2str(lastX) ' and the currentX is ' num2str(currentX)])
            if (TargetYReal(currentY) && IsEquivalentReal(currentX, lastX))
                disp(['the robot is trapped']);
                SetFwdVelRadiusRoomba(serPort, 0, inf);
                return
            end

            disp([currentX, currentY, angle]);
        end


        if (TargetYReal(currentY) && IsEquivalentReal(currentX, 4))
            SetFwdVelRadiusRoomba(serPort, 0, inf);
            disp(['Done']);
            return
        end
    end
end


function followTheBound(serPort, inputX)
  global angle currentX currentY;
    max_vel = 0.2;
   [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
   [Wall]= WallSensorReadRoomba(serPort);
    
    % The main while loop
    startMoving = 0;
    while (1)
       
       % The I part: Go straight forward. 
       % Before this loop, we have to record the original isStartPoint. 
       % This is to deal with the problem
       % that sometimes the robot stops at the start point at the
       % beginning, without going anywhere. We Assume that the robot will
       % return to the start point only in the middle of I or III part.
       % beforeLoopIsStartPoint = IsStartPoint(currentX, currentY, initialX, initialY);
       while ((BumpRight==0 && BumpLeft==0 && BumpFront == 0 && Wall == 1))
            SetFwdVelRadiusRoomba(serPort, max_vel, inf);
            pause(0.1);
            [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            [Wall]= WallSensorReadRoomba(serPort);   
            magnitude = DistanceSensorRoomba(serPort);
            currentX = currentX + magnitude * cos(angle);
            currentY = currentY + magnitude * sin(angle);
            % disp(['CURRENTX' num2str(currentX)]);
            disp('go straight forward in followTheBound')
            disp(['the currentY is ' num2str(currentY)])
            if (IsEquivalent(currentY, 0) && startMoving == 1 && ~IsEquivalent(currentX, inputX))
                break
            end
       end
       if IsEquivalent(currentY, 0) && startMoving == 1 && ~IsEquivalent(currentX, inputX)
          disp(['jump out of funciton followTheBoud']);
          return
       end


        % The II Part: Turn left until there is no bump detected.
        % Note that in this part, the robot didn't go any further, so
        % there is no way that the robot returns to the start point after
        % this Part.
        while(BumpRight==1 || BumpLeft==1 || BumpFront == 1)
            turnAngle(serPort, 0.2, 5);
            disp(['turning left']);
            [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
        end
        
        angle = angle + AngleSensorRoomba(serPort);
        
        % The III Part: To find the wall.
        % Since the robot has to walk along the wall, so when the wall
        % sensor is 0, it has to find the wall. 
        % beforeLoopIsStartPoint = IsStartPoint(currentX, currentY, initialX, initialY);
        % DistanceSensorRoomba(serPort);
        while (Wall == 0 && (BumpRight==0 || BumpLeft==0 || BumpFront==0 ))
            disp(['no wall detected']);
            % Turn little left and then go little further.
            turnAngle(serPort, 0.2, -5);
            travelDist(serPort, 0.05, 0.01);
            [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            [Wall]= WallSensorReadRoomba(serPort);
            angle = angle + AngleSensorRoomba(serPort);
            magnitude = DistanceSensorRoomba(serPort);
            currentX = currentX + magnitude * cos(angle);
            currentY = currentY + magnitude * sin(angle);
            disp(['the magnitude is ' num2str(magnitude) ' and the angle is '  num2str(angle)])

            if IsEquivalent(currentY, 0) && startMoving == 1 && ~IsEquivalent(currentX, inputX)
                return
            end
        end
        
       if IsEquivalent(currentY, 0) && startMoving == 1 && ~IsEquivalent(currentX, inputX)
       		return
       end

       startMoving = 1

    end
end



function followTheBoundReal(serPort, inputX)
    global angle currentX currentY;
    max_vel = 0.2;
    %DistanceSensorRoomba(serPort);
    [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    [Wall]= WallSensorReadRoomba(serPort);
    while (1)
       while (BumpRight==0 && BumpLeft==0 && BumpFront == 0 && Wall == 1)
            SetFwdVelRadiusRoomba(serPort, max_vel, inf);
            pause(0.1);
            [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            [Wall]= WallSensorReadRoomba(serPort);   
            magnitude = DistanceSensorRoomba(serPort);
            currentX = currentX + magnitude * cos(angle);
            currentY = currentY + magnitude * sin(angle);
            if (IsEquivalentReal(currentY, 0) && ~IsEquivalentReal(currentX, inputX))
                SetFwdVelRadiusRoomba(serPort, 0, inf);
                return
            end
        end

        while(BumpRight==1 || BumpLeft ==1 || BumpFront == 1 )
            disp([num2str(BumpRight)  num2str(BumpLeft) num2str(BumpFront) num2str(Wall)])
            SetFwdVelRadiusRoomba(serPort, 0.1, eps);
            [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort); 
        end
        SetFwdVelRadiusRoomba(serPort, 0, inf);

        while (Wall == 0 && BumpRight==0 && BumpLeft==0 && BumpFront==0 ) 
            SetFwdVelRadiusRoomba(serPort, 0.1, -0.2);
            angle = angle + AngleSensorRoomba(serPort);
            magnitude = DistanceSensorRoomba(serPort);
            currentX = currentX + magnitude * cos(angle);
            currentY = currentY + magnitude * sin(angle);
            [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            [Wall]= WallSensorReadRoomba(serPort);
        end

        if IsEquivalentReal(currentY, 0) && ~IsEquivalentReal(currentX, inputX)
            SetFwdVelRadiusRoomba(serPort, 0, inf);
            return
        end
        
        angle = angle + AngleSensorRoomba(serPort);
    end
end




function isEquivalent = IsEquivalent(x,y)
    isEquivalent =  abs(x-y) < 0.05
end



function targetY = TargetY(y)
    targetY = abs(y) < 0.2
end


function isEquivalent = IsEquivalentReal(x,y)
    isEquivalent =  abs(x-y) < 0.1
end



function targetY = TargetYReal(y)
    targetY = abs(y) < 0.3
end




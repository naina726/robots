%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMS W4733 Computational Aspects of Robotics 2015
%
% Homework 2
%
% Team number: 21
% Team leader: Yiqing Cui(yc3121)
% Team members: Jasleen Nuno (jn2465)  Naina Prasad (np2302)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function BugII(serPort) 
    global angle currentX currentY
    angle = AngleSensorRoomba(serPort);
    angle = AngleSensorRoomba(serPort);

    currentX = 0;
    currentY = 0;  
    max_vel = 0.2;
   
    
    DistanceSensorRoomba(serPort);

    [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    [Wall]= WallSensorReadRoomba(serPort);

    while 1
        turningAngle = -angle/pi*180
       disp(['in main while loop, the angle is ' num2str(turningAngle)])
       pause(1)
        turnAngle(serPort, 0.2, turningAngle)
        angle = angle + AngleSensorRoomba(serPort);

        pause(1)
%         if abs(turningAngle) > 10
%             disp('done turning to the original direction')
%             return
%         end
        disp(['turning back to the original angle'])
        [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);

        % while the robot is not at the target point and it doesn't hit any
        % wall, go straight forward.
        disp(['after turning, the currentX is ' num2str(currentX) ' the currentY is ' num2str(currentY)])
        %disp(['bumpright is ' num2str(BumpRight) ' bumpleft is ' num2str(BumpLeft) ' BumpFront is ' num2str(BumpFront)] )
        while ((~IsEquivalent(currentX, 4)|| ~TargetY(currentY)) && (BumpRight == 0 && BumpLeft == 0 && BumpFront == 0))
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
        if (TargetY(currentY) && IsEquivalent(currentX, 4))
            disp('Robot has reached the target point');
            SetFwdVelRadiusRoomba(serPort, 0, inf);

            return
        end
        disp(['After CK1, the currentX is ' num2str(currentX) ' and currentY is ' num2str(currentY)])

        %while ((x ~= 0 || y ~= 4) && (x ~= 0 || y ~= last_y) && (x ~= 0 || y <= last_y))
        
        % changed while to if, if the robot is not at target point and the 
        while ((~IsEquivalent(currentX, 4) || ~TargetY(currentY)) && (~IsEquivalent(currentY, 0) || lastX - currentX >= 0 || currentX > 4.1))
            
            disp(['start execute followTheBound'])
            inputX = currentX
            followTheBound(serPort, inputX);
            disp(['after follow the bound the lastX is ' num2str(lastX) ' and the currentX is ' num2str(currentX)])
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


function followTheBound(serPort, inputX)
  global angle currentX currentY;
    max_vel = 0.2;
   
   [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
   [Wall]= WallSensorReadRoomba(serPort);



    % To record that whether the robot has returned to the start point
    
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

function isEquivalent = IsEquivalent(x,y)
    isEquivalent =  abs(x-y) < 0.05
end



function targetY = TargetY(y)
    targetY = abs(y) < 0.2
end
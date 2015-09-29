%**********************************************
% Jasleen Nuno (jn2465)
% Naina Prasad (np2302)
% Yiqing Cui (yc3121)
% Team 21
% Homework 1
%**********************************************
function WallFollow(serPort)
    
    max_vel = 0.4;
    
    [BumpRight, BumpLeft, BumpFront, Wall, virtWall, CliffLft, ...
    CliffRgt, CliffFrntLft, CliffFrntRgt, LeftCurrOver, RightCurrOver, ...
    DirtL, DirtR, ButtonPlay, ButtonAdv, Dist, Angle, ...
    Volts, Current, Temp, Charge, Capacity, pCharge] = AllSensorsReadRoomba(serPort);
    



    % Move EVE forward until she hits a wall
    while (BumpRight==0 && BumpLeft==0 && BumpFront == 0)
         SetFwdVelRadiusRoomba(serPort, max_vel, inf);
         %SetFwdVelRadiusRoomba(serPort, max_vel, -1);

         pause(0.1);
         %disp('after pause')
         [BumpRight, BumpLeft, BumpFront, Wall, virtWall, CliffLft, ...
          CliffRgt, CliffFrntLft, CliffFrntRgt, LeftCurrOver, RightCurrOver, ...
          DirtL, DirtR, ButtonPlay, ButtonAdv, Dist, Angle, ...
          Volts, Current, Temp, Charge, ~, pCharge] = AllSensorsReadRoomba(serPort);
    end

    
    %At this point, it has found a wall/hit something

    % used to keep track of position
    initialX = 0;
    initialY = 0;
    currentX = 0;
    currentY = 0;
    hasStart = 0;
    
    angle = AngleSensorRoomba(serPort);
    magnitude = DistanceSensorRoomba(serPort);

    disp(['first time angle is' num2str(angle)]);
    
    % stop forward movement
    %SetFwdVelRadiusRoomba(serPort, 0, inf);
    pause(0.1);
    
    %THIS IS ONLY RUNNING ONCE
    % line up to move against wall
    
    while (Wall==0 || BumpRight == 1 || BumpLeft == 1 || BumpFront == 1)
        turnAngle(serPort, 0.2, 5);
      [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
      [Wall]= WallSensorReadRoomba(serPort);
    end
    angle = angle + AngleSensorRoomba(serPort);
    disp(['second time angle is' num2str(angle)]);
        
        disp(['outside the loop, currentX is ' num2str(currentX)]);
        disp(['currentY is ' num2str(currentY)])
        disp(['magnitude is ' num2str(magnitude)])
        disp(['angle is ' num2str(angle)])
        
        
        

    % keep track of distance and anglesa
    % angle = AngleSensorRoomba(serPort);
    % magnitude = DistanceSensorRoomba(serPort);

    % loop through until you return to starting position
    
    
    
    
    while (IsStartPoint(currentX, currentY, initialX,  initialY) == 0 || hasStart == 0)
        hasStart = 1
    
        while (BumpRight==0 && BumpLeft==0 && BumpFront == 0 && Wall == 1)
             SetFwdVelRadiusRoomba(serPort, max_vel, inf);
             pause(0.1);
             %disp('after pause')
              [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
               [Wall]= WallSensorReadRoomba(serPort);
              disp('point one')


        end
      magnitude = DistanceSensorRoomba(serPort);
      currentX = currentX + magnitude * cos(angle);
      currentY = currentY + magnitude * sin(angle);
        disp('after first loop')
        disp([num2str(BumpRight) num2str(BumpLeft) num2str(BumpFront) num2str(Wall)])
        
        while(BumpRight==1 || BumpLeft==1 || BumpFront == 1)
            turnAngle(serPort, 0.2, 5);
             [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
        disp('point two')

           
        end

        SetFwdVelRadiusRoomba(serPort, 0, inf);
        while (Wall == 0 && (BumpRight==0 || BumpLeft==0 || BumpFront==0 ))
            turnAngle(serPort, 0.2, -5);
            travelDist(serPort, 0.025, 0.01);
            %SetFwdVelRadiusRoomba(serPort, max_vel, -1);
            [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            [Wall]= WallSensorReadRoomba(serPort);
             disp('inside third loop')

        end
       angle = angle + AngleSensorRoomba(serPort);


       while (BumpRight==0 && BumpLeft==0 && BumpFront == 0 && Wall == 1 && ...
            IsStartPoint(currentX, currentY, initialX,  initialY) == 0)
             SetFwdVelRadiusRoomba(serPort, max_vel, inf);
             pause(0.1);
             %disp('after pause')
              [BumpRight,BumpLeft,a,b,c,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
               [Wall]= WallSensorReadRoomba(serPort);
              disp('point one')
            magnitude = DistanceSensorRoomba(serPort);
            currentX = currentX + magnitude * cos(angle);
            currentY = currentY + magnitude * sin(angle);

        end
        
        
        
        %magnitude = DistanceSensorRoomba(serPort);
        %currentX = currentX + magnitude * cos(angle);
        %currentY = currentY + magnitude * sin(angle);
        disp('after third loop')
        disp([num2str(BumpRight) num2str(BumpLeft) num2str(BumpFront) num2str(Wall)])   



        disp(['inside the loop, currentX is ' num2str(currentX)]);
        disp(['currentY is ' num2str(currentY)])
        disp(['angle is ' num2str(angle)])
        
       




    end
    
    disp(['outside the loop, currentX is ' num2str(currentX)]);
    disp(['currentY is ' num2str(currentY)])
    disp(['hasStart is ' num2str(hasStart)])

end
    
    
    
function isStartPoint = IsStartPoint(currentX, currentY, initialX, initialY)
    isStartPoint ...
        = (currentX - initialX)^2 + (currentY - initialY)^2 < 0.05
end
  
 

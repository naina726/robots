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
    currentX = 1;
    currentY = 1;
    hasStart = 0;
    angle = AngleSensorRoomba(serPort);
    %disp(angle);
    
    % stop forward movement
    %SetFwdVelRadiusRoomba(serPort, 0, inf);
    pause(0.1);
    
    %THIS IS ONLY RUNNING ONCE
    % line up to move against wall
    
    while (Wall==0 || BumpRight == 1 || BumpLeft == 1 || BumpFront == 1)
        turnAngle(serPort, 0.2, 5);
        [BumpRight, BumpLeft, BumpFront, Wall, virtWall, CliffLft, ...
          CliffRgt, CliffFrntLft, CliffFrntRgt, LeftCurrOver, RightCurrOver, ...
          DirtL, DirtR, ButtonPlay, ButtonAdv, Dist, Angle, ...
          Volts, Current, Temp, Charge, Capacity, pCharge] = AllSensorsReadRoomba(serPort);
    end

    % keep track of distance and anglesa
    angle = AngleSensorRoomba(serPort);
    magnitude = DistanceSensorRoomba(serPort);

    % loop through until you return to starting position
    while (currentX ~= initialX || currentY ~= initialY || hasStart == 0)
        hasStart = 1
        disp('Point Three');
       
    
        [BumpRight, BumpLeft, BumpFront, Wall, virtWall, CliffLft, ...
        CliffRgt, CliffFrntLft, CliffFrntRgt, LeftCurrOver, RightCurrOver, ...
        DirtL, DirtR, ButtonPlay, ButtonAdv, Dist, Angle, ...
        Volts, Current, Temp, Charge, Capacity, pCharge] = AllSensorsReadRoomba(serPort);



        while (BumpRight==0 && BumpLeft==0 && BumpFront == 0 && Wall == 1)
             SetFwdVelRadiusRoomba(serPort, max_vel, inf);
             pause(0.1);
             %disp('after pause')
             [BumpRight, BumpLeft, BumpFront, Wall, virtWall, CliffLft, ...
              CliffRgt, CliffFrntLft, CliffFrntRgt, LeftCurrOver, RightCurrOver, ...
              DirtL, DirtR, ButtonPlay, ButtonAdv, Dist, Angle, ...
              Volts, Current, Temp, Charge, ~, pCharge] = AllSensorsReadRoomba(serPort);

        end
        disp('after first loop')
        disp([num2str(BumpRight) num2str(BumpLeft) num2str(BumpFront) num2str(Wall)])
        
        while(BumpRight==1 || BumpLeft==1 || BumpFront == 1)
            turnAngle(serPort, 0.2, 5);
            [BumpRight, BumpLeft, BumpFront, Wall, virtWall, CliffLft, ...
                CliffRgt, CliffFrntLft, CliffFrntRgt, LeftCurrOver, RightCurrOver, ...
                DirtL, DirtR, ButtonPlay, ButtonAdv, Dist, Angle, ...
                Volts, Current, Temp, Charge, Capacity, pCharge] = AllSensorsReadRoomba(serPort);

        end  
        disp('after second loop')
        disp([num2str(BumpRight) num2str(BumpLeft) num2str(BumpFront) num2str(Wall)])        
        
        % while (Wall == 0 && BumpRight==0)
        %     %turnAngle(serPort, 0.2, -5);
        %     SetFwdVelRadiusRoomba(serPort, max_vel, -1);
        %     [BumpRight, BumpLeft, BumpFront, Wall, virtWall, CliffLft, ...
        %         CliffRgt, CliffFrntLft, CliffFrntRgt, LeftCurrOver, RightCurrOver, ...
        %         DirtL, DirtR, ButtonPlay, ButtonAdv, Dist, Angle, ...
        %         Volts, Current, Temp, Charge, Capacity, pCharge] = AllSensorsReadRoomba(serPort);
        % end
        SetFwdVelRadiusRoomba(serPort, 0, inf);
        while (Wall == 0 && (BumpRight==0 || BumpLeft==0 || BumpFront==0 ))
            turnAngle(serPort, 0.2, -5);
            travelDist(serPort, 0.025, 0.01);
            %SetFwdVelRadiusRoomba(serPort, max_vel, -1);
            [BumpRight, BumpLeft, BumpFront, Wall, virtWall, CliffLft, ...
                CliffRgt, CliffFrntLft, CliffFrntRgt, LeftCurrOver, RightCurrOver, ...
                DirtL, DirtR, ButtonPlay, ButtonAdv, Dist, Angle, ...
                Volts, Current, Temp, Charge, Capacity, pCharge] = AllSensorsReadRoomba(serPort);
             disp('inside third loop')
        end
        disp('after third loop')
        disp([num2str(BumpRight) num2str(BumpLeft) num2str(BumpFront) num2str(Wall)])        
        
       
        

        magnitude = DistanceSensorRoomba(serPort);
        newAngle = angle + AngleSensorRoomba(serPort);
        currentX = currentX + magnitude * cosd(newAngle);
        currentY = currentY + magnitude * sind(newAngle);
    end
    
    disp(['outside the loop, currentX is ' num2str(currentX)]);
    disp(['currentY is ' num2str(currentY)])
    disp(['hasStart is ' num2str(hasStart)])
end
    
    
    
 
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OLD CODE TO BE MOVED BACK IN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% % while have not returned to starting point
% while(1)
%     [BumpRight, BumpLeft, BumpFront, Wall, virtWall, CliffLft, ...
%     CliffRgt, CliffFrntLft, CliffFrntRgt, LeftCurrOver, RightCurrOver, ...
%     DirtL, DirtR, ButtonPlay, ButtonAdv, Dist, Angle, ...
%     Volts, Current, Temp, Charge, Capacity, pCharge]   = AllSensorsReadRoomba(serPort);
%     while(BumpRight==0 && BumpLeft==0 && BumpFront==0 && Wall==1)
%         SetFwdVelRadiusRoomba(serPort, 0.5, inf);
%         pause(0.1);
%         [BumpRight, BumpLeft, BumpFront, Wall, virtWall, CliffLft, ...
%         CliffRgt, CliffFrntLft, CliffFrntRgt, LeftCurrOver, RightCurrOver, ...
%         DirtL, DirtR, ButtonPlay, ButtonAdv, Dist, Angle, ...
%         Volts, Current, Temp, Charge, Capacity, pCharge]   = AllSensorsReadRoomba(serPort);
%     end
%     [BumpRight, BumpLeft, BumpFront, Wall, virtWall, CliffLft, ...
%         CliffRgt, CliffFrntLft, CliffFrntRgt, LeftCurrOver, RightCurrOver, ...
%         DirtL, DirtR, ButtonPlay, ButtonAdv, Dist, Angle, ...
%         Volts, Current, Temp, Charge, Capacity, pCharge]   = AllSensorsReadRoomba(serPort);
%     while((BumpLeft==1 || BumpRight==1) || Wall==0)
%         SetFwdVelRadiusRoomba(serPort, 0, inf);
%         if(BumpLeft==0 && BumpRight==0 && Wall==0)
%             turnAngle(serPort, 0.2, 5);
%         elseif((BumpLeft==1 || BumpRight==1) && Wall==0)
%             turnAngle(serPort, 0.1, -5);
%         else
%             turnAngle(serPort, 0.1, -5);
%         end
%     end
% end


% %angleList = [];
% %distanceList = [];
% 
% SetFwdVelRadiusRoomba(serPort, 0.5, inf);
% 
% while(WallSensorReadRoomba(serPort)[1] == 0)
%     SetFwdVelRadiusRoomba(serPort, 0.5, int);
%     pause(0.1);
% end
% 
% distanceTraveled = DistanceSensorRoomba(serPort)[1];
% angleTurned = AngleSensorRoomba(serPort)[1];
% SetFwdVelRadiusRoomba(serPort, 0.0, 0.0);
% 
% while distanceTraveled != 0 && angleTurned != 0
%     while(
%     
% while(WallSensorReadRoomba(serPort)[1] == 1)
%     turnAngle(serPort, 0.2, 5);
%     pause(0.1);
% end
% 
% SetFwdVelRadiusRoomba(serPort, 0.5, int);
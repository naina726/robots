%**********************************************
% Jasleen Nuno (jn2465)
% Naina Prasad (np2302)
% Yiqing Cui (yc3121)
% Team 21
% Homework 1
%
%**********************************************

function WallFollow(serPort)

% Move EVE forward until she hits a wall
while(WallSensorReadRoomba(serPort)== 0)
     SetFwdVelRadiusRoomba(serPort, 0.5, inf);
     pause(0.1);
end

% used to keep track of position
initialX = 0;
initialY = 0;
currentX = 1;
currentY = 1;

% line up to move against wall
while(WallSensorReadRoomba(serPort)==1)
    turnAngle(serPort, 0.2, -5);
end

% keep track of distance and angles
angle = AngleSensorRoomba(serPort);
magnitude = DistanceSensorRoomba(serPort);

% loop through until you return to starting position
while(currentX != initialX && currentY != initialY)
    currentX = 0;
    currentY = 0;
    [BumpRight, BumpLeft, BumpFront, Wall, virtWall, CliffLft, ...
    CliffRgt, CliffFrntLft, CliffFrntRgt, LeftCurrOver, RightCurrOver, ...
    DirtL, DirtR, ButtonPlay, ButtonAdv, Dist, Angle, ...
    Volts, Current, Temp, Charge, Capacity, pCharge] = AllSensorsReadRoomba(serPort);
    
    % continue moving until no longer along the wall
    while(BumpRight==0 && BumpLeft==0 && BumpFront==0 && Wall==1)
        SetFwdVelRadiusRoomba(serPort, 0.5, inf);
        pause(0.1);
    end
    
    % do vector math to keep track of changes in position
    magnitude = DistanceSensorRoomba(serPort);
    newAngle = angle + AngleSensorRoomba(serPort);
    currentX = currentX + magnitude * cosd(newAngle);
    currentY = currentY + magnitude * sind(newAngle);
    
    
    
    
    
       
    
    


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
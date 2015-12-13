function [] = hw5PartI(serPort);

	image = imread('http://192.168.0.101/img/snapshot.cgi?');
    %image = imread('starbuck.jpg');
	imshow(image)
	[totalR, totalC, ~] = size(image);
	[x,y] = ginput(1);
	% Put a cross where they clicked.
	hold on;
	% Get the location they click on.
	row = int32(y);
	column = int32(x);
	pichsv = rgb2hsv(image);
	picvalue = pichsv(row, column, 1);


	%debug
	% newpic = pichsv(:,:,1)  >= picvalue - 0.0 & picvalue <= picvalue + 0.0;
	% imshow(newpic);
	% return

	%[m,n,~]=size(pichsv)
	visited(1:totalR,1:totalC) = 0;

	[areaResult, ~] = findArea(row, column, pichsv, visited);
	[area, ~] = size(areaResult);

	originalArea = area;

	originalCenterR = mean2(areaResult(:,1));
	originalCenterC = mean2(areaResult(:,2));
	showHilight(totalR, totalC, areaResult);
	return;
	maintain the same distance
	while 1
		pause(5);
	    [object] = findLargestBlob();
	    currentCenterC = mean2(object(:,2));

	    % adjust the angle
		while abs(currentCenterC - originalCenterC) > 10
			 if currentCenterC > originalCenterC
			 	turnAngle(serPort, 0.05, 2);
			 else
			 	turnAngle(serPort, 0.05, -2);
			 end
			[object] = findLargestBlob();
	    	currentCenterC = mean2(object(:,2));
	    	showHilight(totalR, totalC, object);

		end

		[area, ~] = size(object);
		% adjust the distance
		while abs(area - originalArea) > 100
			if area > originalArea
				travelDist(serPort, 0.2, -0.25);
			else
				travelDist(serPort, 0.2, 0.25);
			end
			[object] = findLargestBlob();
			[area, ~] = size(object);
	    	currentCenterC = mean2(object(:,2));
	    	showHilight(totalR, totalC, object);

		end


		% adjust the angle again
		while abs(currentCenterC - originalCenterC) > 5
			if currentCenterC > originalCenterC
			 	turnAngle(serPort, 0.05, 5);
			else
			 	turnAngle(serPort, 0.05, -5);
			end
			[object] = findLargestBlob();
	    	currentCenterC = mean2(object(:,2));
	    	showHilight(totalR, totalC, object);

		end

	end

end


function [result, resultVisited] = findArea(startR, startC, hsvpic, visited)
	result = [];
	[m, n, ~] = size(hsvpic);
	qLength = m * n;
	queue(1:qLength, 1:2) = 0;
	%visited(1:m,1:n) = 0;
	hsvvalue = hsvpic(startR, startC);
	disp(['hsv value is' num2str(hsvvalue)]);
	startP = 1;
	endP = 2;
	queue(startP, 1) = startR;
	queue(startP, 2) = startC;
    visited(startR, startC) = 1;
    hsvThreshold = 0.05;
    while startP < endP
    	tempR = queue(startP, 1);
    	tempC = queue(startP, 2);
    	startP = startP + 1;
		[row, ~] = size(result);
		result(row + 1, 1) = tempR;
		result(row + 1, 2) = tempC;
		if tempR + 1 <= m && visited(tempR+1, tempC) == 0 && hsvpic(tempR + 1, tempC) >= hsvvalue - hsvThreshold && hsvpic(tempR + 1, tempC) <= hsvvalue + hsvThreshold
			queue(endP, 1) = tempR + 1;
			queue(endP, 2) = tempC;
			endP = endP + 1;
			visited(tempR+1, tempC) = 1;
		end
		if tempR - 1 >= 1 && visited(tempR - 1, tempC) == 0 && hsvpic(tempR - 1, tempC) >= hsvvalue - hsvThreshold && hsvpic(tempR - 1, tempC) <= hsvvalue + hsvThreshold
			queue(endP, 1) = tempR - 1;
			queue(endP, 2) = tempC;
			endP = endP + 1;
			visited(tempR - 1, tempC) = 1;
		end
		if tempC + 1 <= n && visited(tempR, tempC + 1) == 0 && hsvpic(tempR, tempC + 1) >= hsvvalue - hsvThreshold && hsvpic(tempR, tempC + 1) <= hsvvalue +hsvThreshold
			queue(endP, 1) = tempR ;
			queue(endP, 2) = tempC + 1;
			endP = endP + 1;
			visited(tempR, tempC + 1) = 1;
		end
		if tempC - 1 >= 1 && visited(tempR, tempC - 1) == 0 && hsvpic(tempR, tempC - 1) >= hsvvalue - hsvThreshold && hsvpic(tempR, tempC - 1) <= hsvvalue + hsvThreshold
			queue(endP, 1) = tempR ;
			queue(endP, 2) = tempC - 1;
			endP = endP + 1;
			visited(tempR, tempC - 1) = 1;
		end


    end

    resultVisited = visited;

end

function [] = showHilight(totalR, totalC, pointsList)
	[area, ~] = size(pointsList);
	newpic(1:totalR, 1:totalC) = 0;
	for i = 1:area
		newpic(pointsList(i,1), pointsList(i,2)) = 1;
	end
	imshow(newpic)
end


function [equal] = isEqualCenter(originalCenterC,  currentCenterC)
	equal = abs(originalCenterC - currentCenterC) < 5;
end


function [result] = findObject()
	image = imread('http://192.168.0.101/img/snapshot.cgi?');
    pichsv = rgb2hsv(image);
    [totalR, totalC, ~] = size(image);
    found = 0;
    currentStartR = 0;
    currentStartC = 0;
	for i = 1:totalR
		for j = 1:totalC
			if pichsv(i,j,1) == picvalue
				found = 1;
				currentStartR = i;
				currentStartC = j;
				break;
			end
		end
		if found == 1
			break;
		end
	end
	visited(1:m,1:n) = 0;
	[result, ~] = findArea(currentStartR, currentStartC, pichsv);

	% currentCenterC = mean2(areaResult(:,2));

	showHilight(totalR, totalC, result);
end



function [result] = findLargestBlob()
	image = imread('http://192.168.0.101/img/snapshot.cgi?');
    pichsv = rgb2hsv(image);
    [totalR, totalC, ~] = size(image);
    currentStartR = 0;
    currentStartC = 0;	
    visited(1:m,1:n) = 0;
    maxArea = 0;
    largestArea = [];
	for i = 1:totalR
		for j = 1:totalC
			if pichsv(i,j,1) == picvalue
				currentStartR = i;
				currentStartC = j;
				if visited(m,n) == 1
					continue
				end
				[resultArea, visited] = findArea(currentStartR, currentStartC, pichsv, visited);
				[area, ~] = size(resultArea);
				if area > maxArea
					largestArea = resultArea;
				end
			end
		end
	end
	result = largestArea;
	% currentCenterC = mean2(areaResult(:,2));

	showHilight(totalR, totalC, result);
end




% function required = requiredPoint(targetP, judgeP, threshold)
% 	if judgeP >= targetP - threshold && judgeP <= targetP + threshold
% 		required = 1;
% 	else
% 		required = 0;
% 	end
% end



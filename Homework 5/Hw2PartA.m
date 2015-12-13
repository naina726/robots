    
% read initial image
image = imread('im6.png')
[m,n] = size(image);
disp(m)
disp(n)



pichsv = rgb2hsv(image);

% doorLayer = pichsv(:,:,1)>0.56 &pichsv(:,:,1)<0.675;

direction = 0;

for i = 1:(n/2)
    column_count = 0;
    for j= 1:m
        if pichsv(j,i,1) > 0.56 && pichsv(j,i,1) < 0.675
            column_count = column_count + 1;
        end
    end
    if column_count > m / 2
        direction = i;
        break;
    end
    column_count = 0;       
    for j= 1:m
        if image(j,n-i,1) > 0.56 && image(j,n-i,1) < 0.675:
                    column_count = column_count + 1;
        end
    end
     if column_count > m / 2
         direction = i;
         break;
     end
disp(direction) 
%if direction < (n/2)
    % robot turns left
%else
    % robot turns right
    
%Hw5Part2(serPort);

%end
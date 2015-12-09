function [] = Hw2PartA();
    
% read initial image
image = imread('im6.png')
[m,n] = size(image);

direction = 0;

for i = 1:(n/2)
    column_count = 0;
    for j= 1:m
        if image(j,i,1) > 63 && image(j,i,1) < 73:
            if image(j,i,2) > 79 && image(j,i,2) < 89:
                if image(j,i,3) > 92 && image(j,i,3) < 103:
                    column_count = column_count + 1;
    if (column_count/n) > 0.5
        direction = i;
        break;
    column_count = 0;       
    for j= 1:m
        if image(j,n-i,1) > 63 && image(j,n-i,1) < 73:
            if image(j,n-i,2) > 79 && image(j,n-i,2) < 89:
                if image(j,n-i,3) > 92 && image(j,n-i,3) < 103:
                    column_count = column_count + 1;
                    
     if (column_count/n) > 0.5
         direction = i;
         break;
         
if direction < (n/2)
    % robot turns left
else
    % robot turns right
    
Hw5Part2(serPort);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This is a test script to refocus the depth field for the Monkey/Plant
%  scene in the Depth Fields paper. 
% 
%  Written by Suren Jayasuriya
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% indices to load data
kinecty = [115 90 65 40 15];
kinectx = [5 4 3 2 1];

% Load Light Field (5 x 5 views)
county = 0;
for y= 1:5
    county = county + 1;
    countx = 0;
    for x = 1:5
        countx = countx+1;
        % load image
        data = imread(sprintf('MonkeyPlantScene/col_%0.5g_%0.5g.png',kinectx(x),kinecty(y)));
        % crop image
        data = data(300:700,600:1150,:); 
        % store in lightField
        lightField(county,countx,:,:,:) = im2double(data); 
    end
end

% Load Depth Field (5x5 views)

county = 0;
for y= 1:5 
   county = county + 1;
   countx = 0;
   for x = 1:5
       countx = countx+1;
       % load depth image
       data = imread(sprintf('MonkeyPlantScene/dep_%0.5g_%0.5g.png',kinectx(x),kinecty(y)));
       % crop image
       data = data(120:260,165:345);
       % store in depthField
       depthField(county,countx,:,:) = im2double(data); 
   end
end 

%  Refocusing lightField
count = 0;
for shift=-40:1:40
    count = count+1;
    [Iout] = refocusLightField(lightField,shift);
    LFrefocus(count,:,:,:) = (Iout - min(Iout(:)))./(max(Iout(:))-min(Iout(:)));
end

% visualize refocused light field,
figure,
title('Refocus light field');
for iter=1:count
    imagesc(squeeze(LFrefocus(iter,:,:,:)));
    axis off;
    iter
    pause(0.1)
end
     
 % Refocusing the depth map
count = 0;
for shift=0:1:40
    count = count+1;
    [Iout] = refocusLightField(depthField,shift);
    DFrefocus(count,:,:) = (Iout - min(Iout(:)))./(max(Iout(:))-min(Iout(:)));
end

figure,
title('Refocus depth map')
for iter=1:count
    imagesc(squeeze(DFrefocus(iter,:,:)));
    colormap gray;
    colorbar; colorbar('Ticks',[]);
    axis off;
        iter
        pause(0.1)
end
    
 
    
%% Removing partial occluder

% View depth histogram
figure, histogram(depthField(:),100);
xlabel('depths');
ylabel('pixel count');
title('Histogram of depths');

% step 1 identify occluders (right now, simple model)
% Can manually pick depth clusters or use K-means/other algorithm to find
% values
d1 = 40000; % highest depth value you want to accept
d2 = 0.18; % lowest depth value you want to accept (d1=4000, d2=0.18 gives you the figure in the paper)
thresh = 0.02; % threshold for error comparison

for u=1:size(depthField,1)
    for v=1:size(depthField,2)
        for i=1:size(depthField,3)
            for j=1:size(depthField,4)
                if (abs(depthField(u,v,i,j) - d1)<thresh || abs(depthField(u,v,i,j) - d2)<thresh)
                    mask(u,v,i,j) = 1;
                else mask(u,v,i,j) = 0;
                end
            end
        end
    end
end
% Visualize the mask
figure, drawLightField4D(depthField.*mask);
title('Mask');


% TOF refocusing with new field (only average over non-occluded views)
depthField_mask = depthField.*mask;
count = 0;
for shift=-40:1:40
        count = count+1;
        LFshear = shearLightField(depthField_mask,shift);
        depthrefocus(count,:,:) = zeros(size(depthField,3), size(depthField,4));
        for i=1:size(depthField,3)
            for j=1:size(depthField,4)
                for u=1:size(depthField,1)
                    for v=1:size(depthField,2)
                        if LFshear(u,v,i,j) ~= 0
                            depthrefocus(count,i,j) = 1/2.*depthrefocus(count,i,j) + 1/2.*LFshear(u,v,i,j);
                        end
                    end
                end
            end
        end
 
end
 
% Visualize improved depth map without partial occluder
figure,
title('Improved depth map');
 for iter=1:count
        imagesc(squeeze(depthrefocus(iter,:,:)));
       colormap gray;
       axis off;
        iter
        pause(0.1)
 end


 
 

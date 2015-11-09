%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script to perform phase unwrapping on synthetic and real data 
% Written by Suren Jayasuriya, edits by Ryuichi Tadano
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Cornell Box Scene, synthetic data

depthField = zeros(5,5,512,512);
cd('CornellBox/'); % enter Cornell box directory
county = 0;
for y= 1:5
    county = county + 1;
    countx = 0;
    for x = 1:5
        countx = countx+1;
        t = sprintf('phasewrap%d%d',county,countx);
        eval(t)
        depthField(county,countx,:,:) = data;
    end
end
cd('..'); %exit Cornell Box directory back to main directory
    
% normalize for outliers/visualization (normalize by max of center view, a
% hack to eliminate outliers)
tmp = depthField(3,3,:,:);
depthField = depthField./max(tmp(:));

% View scene 
figure, title('Original Scene'), 
imagesc(squeeze(depthField(3,3,:,:))); colormap gray;
    
% perform synthetic phase wrapping
depthField = 100.*depthField;
wrapvalue = 20; %pick any value from 1 to 50, 1 = more wrapping, 50 = less wrapping
depthField = mod(depthField,wrapvalue);
depthField = 1/wrapvalue.*depthField;
figure, imagesc(squeeze(depthField(3,3,:,:)));
title('Synthetic phase wrapping');

% LF depth estimate
% calculate depth from sheared light field (depth from correspondence from Tao et al.)
count =1;
 for alpha = -20:1:20
      
     % calculate refocused light field at alpha
     shearField = shearLightField(depthField,alpha);
     meanField = refocusLightField(depthField,alpha);
     
     % calculate variation in correspondence
     sigma = zeros(size(meanField));
     for u=1:5
         for v=1:5
             sigma = sigma + (squeeze(shearField(u,v,:,:)) - meanField).^2;
         end
     end
     sigma = sigma./25;
     estdepths(count,:,:) = squeeze(sigma);
     
     count = count+1; %iterate counter
 end
        

% Median Filter
 for i=1:size(estdepths,1)
     estdepths(i,:,:) = medfilt2(squeeze(estdepths(i,:,:)));
 end

% argmin over alpha stack
for y=1:size(estdepths,2)
    for x=1:size(estdepths,3)
         
        % argmin over alphas      
        [a1,ind] = min(estdepths(:,y,x));
        depths(y,x) = ind;
                 
      % find 2nd min for confidence value
        estdepths(ind,y,x) = NaN;
        [a2,ind2] = min(estdepths(:,y,x));
        Conf_corr(y,x) = a1./a2;
                 
    end
end



figure, imagesc(depths); colormap gray; colorbar;
        title('Light Field Depth Estimate-correspondence');
         
figure, imagesc(Conf_corr); colormap gray; colorbar;
        title('Correspondence confidence');


% Determine phase unwrapping statistics (manually pick a fiducial line per
% scene to do the unwrapping). As noted in the paper, this is a very
% limiting assumption, and I welcome any improvements on this part of the
% algorithm.

% I = TOF depth map, depths = LF depth from correspondence
I = squeeze(depthField(3,3,:,:));
% pick line in light field depths and TOF depth
zlf = depths(285,20:168);
ztof = I(285,20:168);
zcomb = [zlf' ztof'];
figure, plot(zcomb(:,2));
hold on, plot((zcomb(:,1)-min(zcomb(:,1)))./(max(zcomb(:,1))-min(zcomb(:,1))),'r');
title('plot depths (Cornell box)');
        
% using plot, estimate function for unwrapping (this is manually done)
valley(1,:) = zcomb(1,:);
peak(1,:) = zcomb(50,1:2);
valley(2,:) = zcomb(51,1:2);
peak(2,:) = zcomb(97,1:2);
valley(3,:) = zcomb(98,1:2);
peak(3,:) = zcomb(125,1:2);
         
% phase unwrap (in TOF terms)
unwrapped = zeros(size(depths));
  
for i=1:size(unwrapped,1)
    for j=1:size(unwrapped,2)
        pixel = depthField(3,3,i,j);
        lfest = depths(i,j);
                 
        if (lfest > valley(1,1))
            unwrapped(i,j) = pixel;
        end
                 
        if (lfest == valley(1,1))
            if pixel <= 0.5
               unwrapped(i,j) = 1 + pixel;
            else
               unwrapped(i,j) = pixel;      
            end
        end  
                 
        if (lfest < valley(1,1) && lfest > valley(2,1))
           unwrapped(i,j) = 1 + pixel;
        end
                 
        if (lfest == valley(2,1))
           if pixel <= 0.5
              unwrapped(i,j) = 2 + pixel;
           else
              unwrapped(i,j) = 1 + pixel;
           end
        end
                 
        if (lfest < valley(2,1) && lfest > valley(3,1))
           unwrapped(i,j) = 2 + pixel;
        end
                 
        if (lfest == valley(3,1))
            if pixel <= 0.5
               unwrapped(i,j) = 3 + pixel;
            else
               unwrapped(i,j) = 2 + pixel;
            end
        end
                 
                 
        if (lfest < valley(3,1))
           unwrapped(i,j) = 3 + pixel;       
        end
   end
end
         
% display unwrapped depth map
unwrapped = unwrapped./max(unwrapped(:));
disp_region = [30, 30, 470, 486];% [xmin, ymin, xman, ymax]
figure, imagesc(unwrapped(disp_region(2):disp_region(4), disp_region(1):disp_region(3)),[0 2]); colorbar; colorbar('Ticks',[]);colormap gray; axis off;
title('unwrapped depth');
         
      
         

       
         
         
         
         


         
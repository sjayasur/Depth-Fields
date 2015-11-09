%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Code originally written by Gordon Wetzstein
% (http://web.stanford.edu/~gordonwz/), modified by Suren Jayasuriya
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function animateLightField(lightField, numLoops)

    lightFieldResolution = size(lightField);

    % indices for animation
    centerY     = round(lightFieldResolution(1)/2);
    indicesY    = centerY:-1:1;
    indicesY    = [indicesY 2:lightFieldResolution(1)];
    indicesY    = [indicesY lightFieldResolution(1)-1:-1:centerY];

    centerX     = round(lightFieldResolution(2)/2);
    indicesX    = centerX:-1:1;
    indicesX    = [indicesX 2:lightFieldResolution(2)];
    indicesX    = [indicesX lightFieldResolution(2)-1:-1:centerX];

    numColorChannels = 1;
    if numel(lightFieldResolution) > 4
        numColorChannels = lightFieldResolution(5);
    end

    frameCount = 1;
    pauseTime = 0.5;
    

    createMovie=0; %Change to 1 if you want to record an animation of the depth field 
    if createMovie
        writerObj = VideoWriter('animation.avi');
        writerObj.FrameRate = 5;
        open(writerObj);
    end
    
    for ll=1:numLoops
        for kx=indicesX   
            I = reshape(lightField(centerY,kx,:,:,:), [lightFieldResolution(3) lightFieldResolution(4) numColorChannels]);
            imshow(I);
            drawnow;
            pause(pauseTime);    
            frameCount=frameCount+1;
          
            if createMovie
                frame = getframe;
                writeVideo(writerObj,frame);
            end
        end

        for ky=indicesY
            I = reshape(lightField(ky,centerX,:,:,:), [lightFieldResolution(3) lightFieldResolution(4) numColorChannels]);
            imshow( I );
            drawnow;
            pause(pauseTime);   
            frameCount=frameCount+1;
            
            if createMovie
                frame = getframe;
                writeVideo(writerObj,frame);
            end
        end
        
    end
        if createMovie
            close(writerObj);
        end
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computationally refocus a light field
% Original code by Gordon Wetzstein
% Edits by Suren Jayasuriya
% input: lightField: UxVxNxMx3 lightfield where UxV is the views of the
% light field, NxM is the resolution, and 3 stands for color channels
% pixels = pixel shift desired
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [Iout ] = refocusLightField(lightField, pixels)
    

    %initialize 
    Iout = zeros([size(lightField,3) size(lightField,4) size(lightField,5)]);
    
   
    for ky=1:size(lightField,1)
        for kx=1:size(lightField,2)
            
            % reshaping lightfield to proper form
            II = reshape(lightField(ky,kx,:,:,:), [size(lightField,3) size(lightField,4) size(lightField,5)] );
            
            for k=1:size(lightField,5)
                % shifting the pixels
                I(:,:,k) = copyshift(II(:,:,k),[pixels*(ky-(floor(size(lightField,1)/2)+1)), pixels*(kx-(floor(size(lightField,2)/2)+1))]);
            end
            % summing up over focal stack
            Iout = Iout + (1/(size(lightField,2)*size(lightField,1))) .* I;
            
        end
    end
    
end
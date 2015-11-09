%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Returns a sheared Light Field
% input: lightField (u,v,x,y,c)
%        pixels = amount you want to shear by
% Original code by Gordon Wetzstein, edits by Suren Jayasuriya
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function shearLF = shearLightField(lightField,pixels)

    %initialize 
    shearLF = zeros(size(lightField));
    
   
    for ky=1:size(lightField,1)
        for kx=1:size(lightField,2)
            
            % reshaping lightfield to proper form
            II = reshape(lightField(ky,kx,:,:,:), [size(lightField,3) size(lightField,4) size(lightField,5)] );
            
            for k=1:size(lightField,5)
                % shifting the pixels
                I(:,:,k) = circshift(II(:,:,k),[pixels*(ky-(floor(size(lightField,1)/2)+1)), pixels*(kx-(floor(size(lightField,2)/2)+1))]);
            end
            % place in shearLF structure
            shearLF(ky,kx,:,:,:) = squeeze(I);
            
        end
    end
    
end
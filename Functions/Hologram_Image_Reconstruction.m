%load in hologram z-stack and reference tif image. Can also load in widefield
%shg signal image (sig), but not necessary for image field reconstruction. 

filename = 'Hologram_zstack_glass_sphere_THG.tif';
tiff_info = imfinfo(filename);
tiff_stack = imread(filename);

for ii = 2 : size(tiff_info,1);
    temp_tiff = imread(filename,ii);
    tiff_stack = cat(3 , tiff_stack, temp_tiff);
end

Holo = double(tiff_stack);
clear filename tiff_stack tiff_info temp_tiff

% filename = 'Sig_glass_sphere_in_focus.tif';
% tiff_info = imfinfo(filename);
% tiff_stack = imread(filename);
% 
% for ii = 2 : size(tiff_info,1);
%     temp_tiff = imread(filename,ii);
%     tiff_stack = cat(3 , tiff_stack, temp_tiff);
% end
% 
% Sig = double(tiff_stack);
% clear filename tiff_stack tiff_info temp_tiff

filename = 'Reference_glass_sphere_THG.tif';
tiff_info = imfinfo(filename);
tiff_stack = imread(filename);

for ii = 2 : size(tiff_info,1);
    temp_tiff = imread(filename,ii);
    tiff_stack = cat(3 , tiff_stack, temp_tiff);
end

Ref = double(tiff_stack);
clear filename tiff_stack tiff_info temp_tiff

%% experimental parameters and axis/grids, depends on SHG holography and THG Holography

%use these parameters for SHG holography (previous HOT data from Jeff)
pixel_size = 6.5;           %physical pixel size of camera in microns  
trans_mag = 39.436;         %magnification of object plane to image plane
NA = 0.9;                   %numerical aperature of collection objective
lambda = 0.518;             %wavelength of light (SHG) in microns

%use these parameters for THG holography (newer holographic microscope setup) 
% pixel_size = 13.3;          %physical pixel size of camera in microns  
% trans_mag = 48.122;         %magnification of object plane to image plane
% NA = 0.45;                  %numerical aperature of collection objective
% lambda = 0.355;             %wavelength of light (THG) in microns

Nx = length(Holo(1,:,1));   %number of pixels
Ny = length(Holo(:,1,1));
dx = pixel_size/trans_mag;  %effective pixel size in microns
x = linspace(0,Nx.*dx,Nx);  % x and y axis in r-space
y = linspace(0,Ny.*dx,Ny)';
[X,Y] = meshgrid(x,y);
kmax = 1./(2.*dx);          % max spatial frequency axis  
kx = linspace(-kmax,kmax,Nx); % spatial frequency axis
ky = linspace(-kmax,kmax,Ny)';
[kX,kY] = meshgrid(kx,ky);


%% First, step is to identify the AC component (side lobe) ,filter it, and then center it in k-space. 
% This is done by taking an fft of a region of interest of a single
% hologram in the z-stack of holograms. The center position of the AC
% component (side lobe) is determined and shifted to the center of k-space
% coordinates, removing the off-axis tilt angle of the reference. This
% center position will then be used throughout all holograms in z-stack
% because the reference tilt angle is kept constant throughout the
% experiment.


HoloAC = (Holo(:,:,1))-Ref(:,:,1);  %subratcting the reference helps the 
                                    %code find the side lobe by reducing 
                                    %the DC component.
                                    %HoloAC is just determined from one
                                    %slice of the z-stack holograms and is
                                    %used in the beginning of processing
                                    %solely for determing the center
                                    %position of the AC side lobe in order
                                    %to subract the off axis tilt of the
                                    %reference used in the experiment. 

sigma = 0.09;                       %size of r-space filter window (square super gaussian) 

[Holo_filter,FilterWindow] = HoloFilterGen3_yrf(HoloAC,sigma); %create a region of interest
%% Find the center of the AC component.
% define a box by selecting two points around a side lobe. First selected 
% point should correspond to the top left point of the box, second selected
% point should correspond to the bottom right point of the box.
% Tip: defining a smaller box is typically better. It is not necessary 
% capture the entire side lobe, when drawing the box to find the center. 
% Ensure that the program finds the "center" of the side lobe, indicated by
% the black dot on the figure.

[Centx Centy] = MeasureReferenceTilt2_yrf(Holo_filter);
%% Define region of interest of raw hologram, apply FFT, and shift in k-space.

close all
[Holo_filter,FilterWindow] = HoloFilterGen3_yrf(Holo(:,:,1),sigma); %typically using the same region of interest as defined previously.
Centered_side_lobe = fftshift(fft2(fftshift(Holo_filter)));
Centered_side_lobe = circshift(Centered_side_lobe,round(Centx),2); %shifts the FFT[hologram] in k space to bring the AC sidelobe to origin of k-space coordinate.            
Centered_side_lobe = circshift(Centered_side_lobe,round(Centy),1); %Centx and Centy can be either positive or negative depending on which side lobe you want. They are complex conj of each other.   
figure();imagesc(abs(Centered_side_lobe));  
clim([0 2.*mean(abs(Centered_side_lobe),'all')])
title('Centered AC component of hologram')

%% E field reconstruction 
% Apply a circular filter to the centered side lobe and take inverse FFT to
% reconstruct field of signal in r-space. 

filter_radius = NA*(1/lambda).*0.45 ; %information captured is limited by NA/lambda radius in k-space, 
                                     %however, can modify size of radius of filter to ensure no overlap of 
                                     %AC singal and DC compoent in reconstruction
Filter_kxky = exp(-(((kx)/(filter_radius)).^2 + ((ky)/(filter_radius)).^2).^4);
Centered_Filtered_side_lobe = Filter_kxky.*(Centered_side_lobe);
%figure();imagesc(Filter_kxky)
%figure();imagesc(kx,ky,abs(Centered_Filtered_side_lobe))
Field_Reconstructed = fftshift(ifft2(ifftshift(Centered_Filtered_side_lobe)));
figure();
subplot(2,2,1);daspect([1 1 1])
imagesc(x,y,Holo(:,:,1))
title('Unaltered Hologram')
xlabel('x (\mum)');ylabel('y (\mum)');
subplot(2,2,2);daspect([1 1 1])
imagesc(kx,ky,abs(fftshift(fft2(fftshift(Holo_filter)))));clim([0 2.*mean(abs(fftshift(fft2(fftshift(Holo_filter)))),'all')])
title('FFT of ROI of hologram')
xlabel('kx (\mum^-^1)');ylabel('ky (\mum^-^1)');
subplot(2,2,3);daspect([1 1 1])
imagesc(kx,ky,abs(Centered_Filtered_side_lobe));clim([0 2.*mean(abs(fftshift(fft2(fftshift(Holo_filter)))),'all')])
title('Centered & Filtered AC signal')
xlabel('kx (\mum^-^1)');ylabel('ky (\mum^-^1)');
subplot(2,2,4);daspect([1 1 1])
imagesc(x,y,abs(Field_Reconstructed))
title('|Signal E-Field|')
xlabel('x (\mum)');ylabel('y (\mum)');

% Final figure should show an overview of the process that was done with
% the above sections. If everything looks reasonable, the filtering,
% centering, and reconstruction of the signal field for each hologram in
% the z-stack can be done. The same r-space region of interest window and
% circlar k-space filter will be applied throughout the z-stack. 

%% Perform signal E-field reconstruction for entire hologram z-stack
close all

Reconstructed_zstack = zeros(length(Holo(:,1,1)),length(Holo(1,:,1)),length(Holo(1,1,:)));

for i = 1:length(Holo(1,1,:))

    Holo_filter_temp = FilterWindow.*Holo(:,:,i);
    Centered_side_lobe_temp = fftshift(fft2(fftshift(Holo_filter_temp)));
    Centered_side_lobe_temp = circshift(Centered_side_lobe_temp,round(Centx),2);         
    Centered_side_lobe_temp = circshift(Centered_side_lobe_temp,round(Centy),1);
    Centered_Filtered_side_lobe_temp = Filter_kxky.*(Centered_side_lobe_temp);
    Reconstructed_zstack(:,:,i) = fftshift(ifft2(ifftshift(Centered_Filtered_side_lobe_temp)));

    %figure(1);imagesc(abs(Reconstructed_zstack(:,:,i)));
    %pause(0.2)
end

clear Holo_filter_temp Centered_side_lobe_temp Centered_Filtered_side_lobe_temp
%% Save reconstructed E-Field z-stack as a tif

%saveastiff(Reconstructed_zstack,'E-field_zstack_Jeff_BBO_SHG_HOT.tif')



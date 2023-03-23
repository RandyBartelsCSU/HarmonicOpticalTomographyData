function [Holo_filter,FilterWindow]=HoloFilterGen3_yrf(Hologram,sigma);


% This function generates a filter for the hologram in R-space. The filter in R-space is designed
% to mitigate ringing artifacts when taking fourier transforms of the
% hologram due to non-zero values near the edge of the field of view. 

% Inputs:

% datasize: vector containing size (in pixels) of hologram [row column]





% holoinfo=h5info(filename,'/Epi/Hologram');
% count=holoinfo.ChunkSize;
% Epiinfo=h5info(filename,'/Epi');
% datainfo=Epiinfo.Datasets.Dataspace;
% datasize=datainfo.Size;

Nx=length(Hologram(1,:));
Ny=length(Hologram(:,1));

%Nx = 1024;
%Ny = 1024;

x=linspace(0,1,Nx);
y=linspace(0,1,Ny);

[X Y]=meshgrid(x,y);

imagesc(Hologram)
title('Select center of position of Holo signal')
[xn yn]=ginput(1);
xn= round(xn)./Nx;
yn= round(yn)./Ny;


FilterWindow=exp(-((X-xn).^2/sigma).^4).*exp(-((Y-yn).^2/sigma).^4);
%FilterHolo=exp(-((X-.65).^2/sig2).^4).*exp(-((Y+.7).^2/sig2).^4);

% figure; 
% 
% imagesc(FilterHolo)
% daspect([1 1 1])
% %axis off
% title('Filter for R-space Hologram')
% figure;
% tiledlayout(1,2)
% nexttile
% plot(FilterHolo(round(end/2),:))
% title('y-dir lineout')
% nexttile
% plot(FilterHolo(:,round(end/2)))
% title('x-dir lineout')




Holo_filter = FilterWindow.*Hologram;

figure();imagesc(Holo_filter);
title('Filtered Holo')

end




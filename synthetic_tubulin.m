% imgSize = [341, 341];

clear all;
close all;
nTry = 6;

gardenSize = [500, 500]; % x and y, um
cropSize = [300,300];

brightness = 120;

walkLength = 300;  % step, growth time
dk = 0.02;  % stiffness: higher, more flexible
v0 = 3;  % grow speed (um/step): higher, faster
tubulinNum = 70; % number of tubulins

trajectory = zeros(walkLength+1, 2, tubulinNum);
% grow from x axis

for i = 1 : round(tubulinNum/2)
    x0 = gardenSize(1)*rand(1) + 0*j;
    k0 = 0.25 + 0.05*(rand(1)-0.5)*2;
    kmin = 0.2;
    kmax = 0.3;
    [trajectory(:,1,i), trajectory(:,2,i)] = gen_tubulin(walkLength, dk, k0, kmin, kmax, v0, x0);    
end


% grow from y axis
for i = round(tubulinNum/2)+1 : tubulinNum
    x0 = 0 + gardenSize(2)*rand(1)*j;
    k0 = 0.05*(rand(1)-0.5)*2;
    kmin = -0.1;
    kmax = 0.1;
    [trajectory(:,1,i), trajectory(:,2,i)] = gen_tubulin(walkLength, dk, k0, kmin, kmax, v0, x0);    
end

figure;
for i = 1 : tubulinNum    
    scatter(trajectory(:,1,i), trajectory(:,2,i), 10, 'k','fill'); hold on;
end
hold off;
axis equal;


img = zeros(cropSize);
for i = 1 : tubulinNum
    
    for p = 1 : walkLength
        tX = trajectory(p, 1, i);
        tY = trajectory(p, 2, i);
        
        if ( (tX > (gardenSize(1)-cropSize(1))/2 + 1) && (tX < (gardenSize(1)+cropSize(1))/2 - 1) && ...
                (tY > (gardenSize(2)-cropSize(2))/2 + 1) && (tY < (gardenSize(2)+cropSize(2))/2 - 1) )
            iX = tX - (gardenSize(1)-cropSize(1))/2 ;
            iY = tY - (gardenSize(2)-cropSize(2))/2 ;
            img(floor(iY), floor(iX)) = img(floor(iY), floor(iX)) + 0.25 * brightness;
            img(floor(iY), ceil(iX)) = img(floor(iY), ceil(iX)) + 0.25 * brightness;
            img(ceil(iY), floor(iX)) = img(ceil(iY), floor(iX)) + 0.25 * brightness;
            img(ceil(iY), ceil(iX)) = img(ceil(iY), ceil(iX)) + 0.25 * brightness;
        end
    end
    
end



out = flipud(img);
out = imgaussfilt(out,1.5);
out = uint8(out);


out_noise = imnoise(out,'gaussian',1/255,0.000005);
figure;
mesh(out_noise);
figure;
imagesc(out_noise, [0, 30]);
colormap('hot')
colorbar;

saveName = sprintf('./tubulins%d.tif', nTry);
saveName2 = sprintf('./tubulins_noise%d.tif', nTry);
write3d(out, saveName);
write3d(out_noise, saveName2);

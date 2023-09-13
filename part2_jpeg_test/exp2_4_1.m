%该步骤可以在变换域中进行
%预处理对每个像素的灰度值减去128，相当于对图像灰度整体做平移
%即只改变了图像的直流分量，图像的交流分量没有改变
%因此是否做预处理，在变换域的表现为直流分量值发生变化，即左上角的数值变化
close all;
clear;
hall=load('hall.mat');
area=64;
figure('Name','原始灰度图像64×64');
imshow(hall.hall_gray(1:area,1:area));

figure('Name','预处理后的DCT变换');
hall_dct=dct2(double(hall.hall_gray(1:area,1:area))-ones(area)*128,[area,area]);
imshow(hall_dct);

figure('Name','未预处理的DCT变换');
hall_dct_2=dct2(double(hall.hall_gray(1:area,1:area)),[area,area]);
hall_dct_2(1,1)=hall_dct_2(1,1)-128*area;
imshow(hall_dct_2);
hall_idct=idct2(hall_dct_2);
%计算两个矩阵之间的均方误差
mse=(mean((hall_dct-hall_dct_2).^2))';
mse=reshape(mse,[8,8]);

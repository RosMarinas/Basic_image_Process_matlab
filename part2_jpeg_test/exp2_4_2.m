close all;
clear;
hall=load('hall.mat');
%编程实现二维DCT
    % 这里为方便起见，直接对整个图像做了DCT变换
    [w,h]=size(hall.hall_gray);
    D1=D_calculate(w);%D_calculate是用于计算D矩阵的
    D2=D_calculate(h);
    hall_mandct2=D1*(double(hall.hall_gray)-ones(size(hall.hall_gray))*128)*D2';
    figure('Name','手写DCT变换');
    imshow(hall_mandct2);
%MATLAB自带的库函数dct2
figure('Name','MATLAB自带的库函数');
hall_libdct2=dct2(double(hall.hall_gray)-ones(size(hall.hall_gray))*128);
imshow(hall_libdct2);
%手搓DCT与库函数之间的误差
mse=mean((hall_mandct2-hall_libdct2).^2)';
%D_calculate用于计算D矩阵：
% function D=D_calculate(x)
%     D=zeros(x,x);
%     for j=1:x
%         for i=1:x
%             if i~=1
%                 D(i,j)=cos((2*j-1)*pi*(i-1)/(2*x));
%             else
%                 D(i,j)=1/sqrt(2);
%             end
%         end
%     end
%     D=D*sqrt(2)/sqrt(x);
% end

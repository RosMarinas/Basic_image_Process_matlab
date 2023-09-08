close all;
clear;
%以测试图像的中心为圆心，图像的长和宽中较小值的一半为半径画一个红颜色的圆
hall=load("hall.mat");
figure;
image(hall.hall_color);
imwrite(hall.hall_color,'hall_color.jpg');
hall_color=imread('hall_color.jpg');
hall_color_size=size(hall_color);
radius=min(hall_color_size(1:2))/2;
%画圆的两种方式
    %1. 调用rectangle函数
    rectangle('Position',[hall_color_size(2)/2-radius,hall_color_size(1)/2-radius,2*radius,2*radius],'Curvature',[1 1],'EdgeColor','r');
    axis equal;
    
    saveas(gcf,'hall_color_circle_out1.jpg');
    %2. 调用viscircles函数
    figure;
    image(hall.hall_color);
    viscircles([hall_color_size(2)/2,hall_color_size(1)/2],radius,'Color','r');
    axis equal;
    saveas(gcf,'hall_color_circle_out2.jpg');

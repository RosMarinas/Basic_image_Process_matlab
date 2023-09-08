close all;
clear;
%国际象棋
hall=load("hall.mat");
figure;
image(hall.hall_color);
imwrite(hall.hall_color,'hall_color.jpg');
hall_color=imread('hall_color.jpg');
[hall_color_h,hall_color_w,hall_color_channels]=size(hall_color);
%逐像素操作
for i = 1:20:hall_color_h
    for j = 1:20:hall_color_w
        if mod((i-1)/20+(j-1)/20,2)==0
            for m=1:20
                for n=1:20
                    if(j-1+n<=hall_color_w&&i-1+m<=hall_color_h)
                        hall_color(i+m-1,j+n-1,1)=0;
                        hall_color(i+m-1,j+n-1,2)=0;
                        hall_color(i+m-1,j+n-1,3)=0;
                    end
                end
            end
        end
    end
end
image(hall_color)
imwrite(hall_color,'hall_color_black.jpg');
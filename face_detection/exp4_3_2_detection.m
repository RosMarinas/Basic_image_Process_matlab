%人脸检测
close all;
clear;
clc;
load('feature_extraction.mat');
L=5;
block_noise=10;%噪声阈值，用来抛弃过小的噪声项
block_threshold_down=600;%脸部大小下限，用来排除手等因素干扰，正常人的脸都比手大
block_threshold_up=4000;%脸部大小上限
ratio=2;%脸部的长宽比上限，用来排除胳膊大腿等细长物体干扰
test_img=imread('test2.jpg');
%imshow(test_img);
[row,column,color]=size(test_img);
%将图片按4*4进行分割
width=4;
row_div=floor(row/width)+1;
column_div=floor(column/width)+1;
judge=zeros(row_div,column_div);
%阈值
threshold=0.08;

%块内判断
for i=1:row_div
    for j=1:column_div
        %取出block
        test_block=test_img(width*(i-1)+1:min(row,width*i),4*(j-1)+1:min(column,width*j),:);
        u=feature_extr(test_block,L);
        %判断
        angle=sqrt(u')*sqrt(v);
        if angle>threshold
            judge(i,j)=1;
        end
    end
end
%画框
[judge_bound,~]=bwboundaries(judge);
block_num=size(judge_bound,1);

block_flag=zeros(row,column);
for i=1:block_num
     [length_block ~]=size(judge_bound{i,1});
    if length_block<block_noise
        continue;
    end
    x_min = min(judge_bound{i,1}(:,1))*4;
    x_max = max(judge_bound{i,1}(:,1))*4;
    y_min = min(judge_bound{i,1}(:,2))*4;
    y_max = max(judge_bound{i,1}(:,2))*4;
    w=x_max-x_min;
    h=y_max-y_min;
    if(w*h>block_threshold_down&&w*h<block_threshold_up&&block_flag(x_min,y_min)==0&&(max([h,w])/min([h,w])<ratio))
        hold on;
        %rectangle('Position',[x_min,y_min,x_max,y_max],'Curvature',0.2,'EdgeColor','b');
        %rectangle不好用，就直接在图上将像素值设为255,0,0了
        test_img(x_min,y_min:y_max,1)=0;
        test_img(x_min,y_min:y_max,2)=255;
        test_img(x_min,y_min:y_max,3)=0;

        test_img(x_max,y_min:y_max,1)=0;
        test_img(x_max,y_min:y_max,2)=255;
        test_img(x_max,y_min:y_max,3)=0;

        test_img(x_min:x_max,y_min,1)=0;
        test_img(x_min:x_max,y_min,2)=255;
        test_img(x_min:x_max,y_min,3)=0;

        test_img(x_min:x_max,y_max,1)=0;
        test_img(x_min:x_max,y_max,2)=255;
        test_img(x_min:x_max,y_max,3)=0;
        block_flag(x_min+1:x_max-1,y_min+1:y_max-1)=1;
        
    end
end
imshow(test_img);
hold off;




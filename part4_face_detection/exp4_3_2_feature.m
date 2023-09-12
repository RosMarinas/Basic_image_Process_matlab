%人脸识别
close all;
clear;
clc;
%特征训练
L=5;
v=zeros(2^(3*L),1);
for i=1:33%33为训练集的照片张数
    v=v+feature_extr(imread(['Faces/' num2str(i) '.bmp']),L);
end
v=v/33;
plot(v);
title('特征-概率密度');
xlabel('index');
ylabel('概率');
set(gca,'YLim',[0 0.007]);
save feature_extraction.mat v

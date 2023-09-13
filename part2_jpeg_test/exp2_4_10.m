%计算压缩比
%有非常简单的168*120*8/(length(AC_code)+length(DC_code)+length(h)+length(w))
%但是这里我想要使用一下函数作用于矩阵的每一个元素，就采用了如下的方法
%事实上，在计算DC_code时，就可以使用这种方法，避免使用循环
close all;
clear;
clc;

global origin2bin;

origin2bin=[];
load ('hall.mat');
origin=reshape(hall_gray,1,[]);
arrayfun(@comple,origin)
origin_size=length(origin2bin);

load('jpegcodes.mat');
compress=length(AC_code)+length(DC_code)+length(h)+length(w);
compression_ratio=double(origin_size/compress);
disp(['compression_ratio=',num2str(compression_ratio)]);

function comple(x)
    global origin2bin;
          y=dec2bin(x,8);    
      y=y-'0';
      origin2bin=[origin2bin,y];
end


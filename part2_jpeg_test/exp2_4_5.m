%差分编码目的是更多地保留低频分量中的差异信息，因此直觉上来看就是一个高通滤波器
%其序列的递推式为与y(n)=x(n-1)-x(n)
%z变换后结果为H(z)=z^(-1)-1
close all;
clear;
clc;
b=[1 -1];
a=[1];

freqz(b,a);
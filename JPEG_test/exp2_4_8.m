close all;
clear;
clc;
%分块、DCT、量化
hall=load('hall.mat');
parameter=load('JpegCoeff.mat');

DC_offset=ones(8)*128;
hall_dct2=zeros(size(hall.hall_gray));
hall_quan=zeros(size(hall.hall_gray));
hall_quan_zigzag=zeros(64,(120*168)/64);
QTAB=parameter.QTAB./2;
for i = 1:8:168
    for j = 1:8:120
        hall_dct2(j:j+7,i:i+7)=dct2(double(hall.hall_gray(j:j+7,i:i+7))-DC_offset);
        hall_quan(j:j+7,i:i+7)=round(hall_dct2(j:j+7,i:i+7)./QTAB);
        hall_quan_zigzag(:,21*round((j-1)/8)+round((i-1)/8)+1)=zig_zag(hall_quan(j:j+7,i:i+7));
    end
end
%结果保存在'exp2_4_8_out.mat'
save('exp2_4_8_out.mat','hall_quan_zigzag');

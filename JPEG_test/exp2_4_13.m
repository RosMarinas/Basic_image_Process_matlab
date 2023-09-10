%对雪花的编解码
close all;
clear;
clc;
load('snow.mat');
imshow(snow);
load('JpegCoeff.mat');

DC_offset=ones(8)*128;
snow_dct2=zeros(size(snow));
snow_quan=zeros(size(snow));
snow_quan_zigzag=zeros(64,(128*160)/64);

for i = 1:8:160
    for j = 1:8:128
        snow_dct2(j:j+7,i:i+7)=dct2(double(snow(j:j+7,i:i+7))-DC_offset);
        snow_quan(j:j+7,i:i+7)=round(snow_dct2(j:j+7,i:i+7)./QTAB);
        snow_quan_zigzag(:,20*round((j-1)/8)+round((i-1)/8)+1)=zig_zag(snow_quan(j:j+7,i:i+7));
    end
end
%结果保存在'exp2_4_8_out.mat'
save('snow_quan_zigzag_out.mat','snow_quan_zigzag');

[h,w]=size(snow);
%DC系数差分编码
DC_data=snow_quan_zigzag(1,:);
DC_diffcode=DC_data;
DC_code=[];
i=2;
for i =2:max(size(DC_data))
    DC_diffcode(i)=DC_data(i-1)-DC_data(i);
end
i=1;
for i=1:max(size(DC_data))
    %确定Category及其huffman编码，并将后者添加到DC_code中
    if DC_diffcode(i)==0
        DC_code=[DC_code,[0,0]];
    else
        n=floor(log2(abs(DC_diffcode(i))))+1;
        DC_code=[DC_code,DCTAB(n+1,2:(DCTAB(n+1,1)+1))];
    end
    %确定预测误差的huffman编码并添加到DC_code中
    if DC_diffcode(i)~=0
        DC_code=[DC_code,complement(DC_diffcode(i))];
    end
end

%AC系数编码
AC_code=[];
uint8 run;
uint8 count;
run=0;
i=1;
for i=1:320
    count=nnz(snow_quan_zigzag(2:64,i));
    for j=2:64
        if count==0
            AC_code=[AC_code,[1,0,1,0]];
            break;
        else
            if snow_quan_zigzag(j,i)==0
                run=run+1;
                if run==16
                    AC_code=[AC_code,[1,1,1,1,1,1,1,1,0,0,1]];
                    run=0;
                end
            else 
                n=floor(log2(abs(snow_quan_zigzag(j,i))))+1;
                AC_code=[AC_code,ACTAB(run*10+n,4:(ACTAB(run*10+n,3)+3))];
                AC_code=[AC_code,complement(snow_quan_zigzag(j,i))];
                count=count-1;
                run=0;
            end
        end
    end
end
w=complement(w);
h=complement(h);
save('snow_jpegcodes.mat','DC_code','AC_code','w','h');


global origin2bin;

origin2bin=[];
origin=reshape(snow,1,[]);
arrayfun(@comple,origin)
origin_size=length(origin2bin);

load('snow_jpegcodes.mat');
compress=length(AC_code)+length(DC_code)+length(h)+length(w);
compression_ratio=double(origin_size/compress);
disp(compression_ratio);




global huffman_table;
load('snow_jpegcodes.mat');
load('JpegCoeff.mat');
load('snow_quan_zigzag_out.mat');

huffman_table={
    '0','00';
    '1','010';
    '2','011';
    '3','100';
    '4','101';
    '5','110';
    '6','1110';
    '7','11110';
    '8','111110';
    '9','1111110';
    '10','11111110';
    '11','111111110';
};
%DC系数解码
%huffman解码得到category，根据category解出magnitude
encode='';
diffcode =[];
i=1;
while i<length(DC_code)
    encode=[encode num2str(DC_code(i))];
    match=find(strcmp(huffman_table(:,2),encode));
    if ~isempty(match)
        category=str2num(huffman_table{match,1});  
        diffcode=[diffcode,icomplement(num2str(DC_code(i+1:i+category)))];
        encode='';
        i=i+category;
    end
    i=i+1;
end
%DC系数
DC_quant=[diffcode(1)];
for i=1:length(diffcode)-1
    DC_quant=[DC_quant,(DC_quant(i)-diffcode(i+1))];
end

%AC系数解码
%huffman解码得到category，根据category解出Amp
EOB=[1,0,1,0];
ZRL=[1,1,1,1,1,1,1,1,0,0,1];
RunSize=[0,0];
encode=[];%待解码，需要从AC_code中取出
accode=[];%解出的ac码
ac_huff_code=[];%ACTAB中取出的huffman编码
i=1;
j=1;
while i<=length(AC_code)
    encode=[encode AC_code(i)];
    if length(encode)==4
            if encode==EOB
                %RunSize=[0,0];
                accode=[accode,zeros(1,63-mod(length(accode),63))];
                %结束并更新
                i=i+1;
                encode=[];
                continue;
            end
    end
    if length(encode)==11
            if encode==ZRL
                %RunSize=[16,0];
                accode=[accode,zeros(1,16)];
                %结束并更新
                i=i+1;
                encode=[];
                continue;  
            end
    end
    %先找到对应的码长，再逐个比较，从而减少比较次数
    [temp,~,~]=find(ACTAB(:,3)==length(encode));
    for j=1:length(temp)
        ac_huff_code=ACTAB(temp(j),4:length(encode)+3);
        if isequal(ac_huff_code,encode)
            RunSize=[ACTAB(temp(j),1),ACTAB(temp(j),2)];
            accode=[accode,zeros(1,RunSize(1))];
            accode=[accode,icomplement(num2str(AC_code(i+1:i+RunSize(2))))];
            %结束并更新
            encode=[];
            i=i+RunSize(2);
            continue;
        end
    end
    i=i+1;
end
h=icomplement(num2str(h));
w=icomplement(num2str(w));
accode=reshape(accode,[63,h*w/64]);
error=accode-snow_quan_zigzag(2:64,:);
snow_quant_izigzag(1,:)=DC_quant;
snow_quant_izigzag(2:64,:)=accode;
%逆zigzag

snow_quant=[h,w];
m=1;
for r=1:8:h
    for s=1:8:w
        snow_quant(r:r+7,s:s+7)=izig_zag(snow_quant_izigzag(:,m));
        m=m+1;
        snow_dct(r:r+7,s:s+7)=snow_quant(r:r+7,s:s+7).*QTAB;
        snow_out(r:r+7,s:s+7)=double(idct2(snow_dct(r:r+7,s:s+7)))+ones(8)*128;
    end
end
imshow(snow);
figure;
imshow(uint8(snow_out));
mse=sum(sum((double(snow_out)-double(snow)).^2))/numel(snow);
PSNR=10*log10(255^2/mse);
disp(['PSNR=',num2str(PSNR)]);

% huffman函数(没有用上)
% function decode_data=huffmandecode(encode_data)
%     global huffman_table;
%     decode_data='';
%     current_data='';
% 
%     for bit=encode_data
%         current_data=[current_data bit];
%         match=find(strcmp(huffman_table(:,2),current_data));
%         if ~isempty(match)
%             decode_data=[decode_data huffman_table{match,1}];
%             current_data = '';
%         end
%     end
% end
function comple(x)
    global origin2bin;
          y=dec2bin(x,8);    
      y=y-'0';
      origin2bin=[origin2bin,y];
end


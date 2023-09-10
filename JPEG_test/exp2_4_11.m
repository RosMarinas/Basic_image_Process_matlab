%解码

close all;
clear;
clc;
global huffman_table;
load("randi_test.mat");
hall_gray=randi_test;
load('jpegcodes.mat');
load('JpegCoeff.mat');
load('exp2_4_8_out.mat');
QTAB=QTAB./2;
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
count=0;
while i<=length(AC_code)
    encode=[encode AC_code(i)];
    if length(encode)==4
            if encode==EOB
                %RunSize=[0,0];
                accode=[accode,zeros(1,63-mod(length(accode),63))];%63-(length(accode)-63*count))
                %结束并更新
                count=count+1;
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
error=accode-hall_quan_zigzag(2:64,:);
hall_quant_izigzag(1,:)=DC_quant;
hall_quant_izigzag(2:64,:)=accode;
%逆zigzag

hall_quant=[h,w];
m=1;
for r=1:8:h
    for s=1:8:w
        hall_quant(r:r+7,s:s+7)=izig_zag(hall_quant_izigzag(:,m));
        m=m+1;
        hall_dct(r:r+7,s:s+7)=hall_quant(r:r+7,s:s+7).*QTAB;
        hall(r:r+7,s:s+7)=double(idct2(hall_dct(r:r+7,s:s+7)))+ones(8)*128;
    end
end
imshow(uint8(hall_gray));
figure;
imshow(uint8(hall));
mse=sum(sum((double(hall)-double(hall_gray)).^2))/numel(hall);
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
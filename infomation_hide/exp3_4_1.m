%变换域隐藏方法
close all;
clear;
clc;
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
%分块、DCT、量化
load('hall.mat');
load('JpegCoeff.mat');
hall_size=size(hall_gray);
hall_h=hall_size(1);
hall_w=hall_size(2);
figure("Name","原图");
imshow(uint8(hall_gray));
%-----------------------------------------信息隐藏------------------------------------------
%信息编码:info_code内容包括:Category,长,Category,宽,信息的二进制流
info='Message In A Bottle';
disp(["info:",info]);
%将信息编码为二维的二进制矩阵，每一行都是一个字符
info_bin=logical(dec2bin(double(info),8)-'0');
%获取上述二进制矩阵的长和宽
info_size=size(info_bin);
%类似于DC系数的形式存储矩阵的长度与宽度信息,显然这两个数都是正整数
info_code=[];
i=1;
for i=1:2
    n=floor(log2(abs(info_size(i))))+1;
    info_code=[info_code,DCTAB(n+1,2:(DCTAB(n+1,1)+1))];  
    info_code=[info_code,complement(info_size(i))];
end
info_bin=reshape(info_bin,[1,info_size(1)*info_size(2)]);
info_code=[info_code,info_bin];
hall_bin=logical(dec2bin(double(hall_gray),8)-'0');
hall_bin(1:length(info_code),8)=info_code';
hall_ibin=bin2dec(num2str(hall_bin));
hall_ibin=reshape(bin2dec(num2str(hall_bin)),[hall_h,hall_w]);
figure("Name","信息隐藏后的图片");
imshow(uint8(hall_ibin));
%-----------------------------------------信息解码-----------------------------------------
hall_bin_find=reshape(hall_ibin,[hall_h*hall_w,1]);
hall_bin_find=logical(dec2bin(double(hall_bin_find),8)-'0');
info_code_find=hall_bin_find(:,8)';

encode='';
info_size_decode =[];
i=1;
count=0;
while i<length(info_code_find)&&count<2
    encode=[encode num2str(info_code_find(i))];
    match=find(strcmp(huffman_table(:,2),encode));
    if ~isempty(match)
        category=str2num(huffman_table{match,1});  
        info_size_decode=[info_size_decode,icomplement(num2str(info_code_find(i+1:i+category)))];
        encode='';
        i=i+category;
        count=count+1;
    end
    i=i+1;
end
info_ibin=info_code_find(i:i+info_size_decode(1)*info_size_decode(2)-1);
info_ibin=reshape(info_ibin,[info_size_decode(1),info_size_decode(2)]);
info_debin=char(bin2dec(num2str(info_ibin)))';
disp(["info_debin:",info_debin]);
%-----------------------------------------dct量化------------------------------------------
DC_offset=ones(8)*128;
hall_dct2=zeros(size(hall_gray));
hall_quan=zeros(size(hall_gray));
hall_quan_zigzag=zeros(64,(120*168)/64);
%QTAB=QTAB;
for i = 1:8:168
    for j = 1:8:120
        hall_dct2(j:j+7,i:i+7)=dct2(double(hall_gray(j:j+7,i:i+7))-DC_offset);
        hall_quan(j:j+7,i:i+7)=round(hall_dct2(j:j+7,i:i+7)./QTAB);
        hall_quan_zigzag(:,21*round((j-1)/8)+round((i-1)/8)+1)=zig_zag(hall_quan(j:j+7,i:i+7));
    end
end
%结果保存在'exp2_4_8_out.mat'
save('exp2_4_8_out.mat','hall_quan_zigzag');
%save('randi_test.mat','randi_test');

%---------------------------------------------编码----------------------------------------------
[h,w]=size(hall_gray);
%DC系数差分编码
DC_data=hall_quan_zigzag(1,:);
DC_diffcode=DC_data;
DC_code=[];

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

%AC系数差分编码
AC_code=[];
uint8 run;
uint8 count;
run=0;
i=1;
for i=1:max(size(DC_data))
    count=nnz(hall_quan_zigzag(2:64,i));
    for j=2:64
        if count==0
            AC_code=[AC_code,[1,0,1,0]];
            break;
        else
            if hall_quan_zigzag(j,i)==0
                run=run+1;
                if run==16
                    AC_code=[AC_code,[1,1,1,1,1,1,1,1,0,0,1]];
                    run=0;
                end
            else 
                n=floor(log2(abs(hall_quan_zigzag(j,i))))+1;
                AC_code=[AC_code,ACTAB(run*10+n,4:(ACTAB(run*10+n,3)+3))];
                AC_code=[AC_code,complement(hall_quan_zigzag(j,i))];
                count=count-1;
                run=0;
            end
        end
    end
end
w=complement(w);
h=complement(h);
save('jpegcodes.mat','DC_code','AC_code','w','h');
%------------------------------------------压缩比计算-------------------------------------------
compression_ratio=168*120*8/(length(AC_code)+length(DC_code)+length(h)+length(w));
disp(['compression_ration=',num2str(compression_ratio)]);
%---------------------------------------------解码----------------------------------------------

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

figure("Name","JPEG编解码");
imshow(uint8(hall));
mse=sum(sum((double(hall)-double(hall_gray)).^2))/numel(hall);
PSNR=10*log10(255^2/mse);
disp(['PSNR=',num2str(PSNR)]);
%-----------------------------------------抗JPEG-----------------------------------------
hall_bin_find=reshape(uint8(hall),[hall_h*hall_w,1]);
hall_bin_find=logical(dec2bin(double(hall_bin_find),8)-'0');
info_code_find=hall_bin_find(:,8)';

encode='';
info_size_decode =[];
i=1;
count=0;
while i<length(info_code_find)&&count<2
    encode=[encode num2str(info_code_find(i))];
    match=find(strcmp(huffman_table(:,2),encode));
    if ~isempty(match)
        category=str2num(huffman_table{match,1});  
        info_size_decode=[info_size_decode,icomplement(num2str(info_code_find(i+1:i+category)))];
        encode='';
        i=i+category;
        count=count+1;
    end
    i=i+1;
end
info_ibin=info_code_find(i:i+info_size_decode(1)*info_size_decode(2)-1);
info_ibin=reshape(info_ibin,[info_size_decode(1),info_size_decode(2)]);
info_debin=char(bin2dec(num2str(info_ibin)))';
disp(["info_debin(after jpeg):",info_debin]);
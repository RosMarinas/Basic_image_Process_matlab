%利用exp2_4_8中的计算结果进一步计算
close all;
clear;
clc;

load('hall.mat');
load('exp2_4_8_out.mat');
load("JpegCoeff.mat");
uint8 i;
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









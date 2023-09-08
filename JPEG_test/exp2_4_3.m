close all;
clear;
clc;
hall=load('hall.mat');
test_hall=double(hall.hall_gray)-ones(size(hall.hall_gray))*128;
test_hall_dct2=zeros(size(test_hall));
test_hall_idct2=zeros(size(test_hall));
figure('Name','原图');
imshow(hall.hall_gray);
%D算子部分系数置为0
    %D右侧四列全部置为0
    %猜测图像应该没有太大变化，因为右侧主要为高频分量
    %且在前例中右侧系数基本为0,图像几乎与不置零相同
    %这里使用的是编程实现的二维DCT
    D=D_calculate(8);
    D(:,5:8)=0;
    for i=1:8:168
        for j=1:8:120
            test_hall_dct2(j:j+7,i:i+7)=D*double(test_hall(j:j+7,i:i+7))*D';
        end
    end
    D=D_calculate(8);
    for i=1:8:168
        for j=1:8:120
            test_hall_idct2(j:j+7,i:i+7)=D'*double(test_hall_dct2(j:j+7,i:i+7))*D;
        end
    end
    test_hall_idct2=double(test_hall_idct2)+ones(size(hall.hall_gray))*128;
    figure('Name','D右侧四列全部置为0');
    imshow(uint8(test_hall_idct2));
    %D左侧四列全部置为0
    %图像会损失大量信息，左侧主要为低频分量
    D=D_calculate(8);
    D(:,1:4)=0;
    for i=1:8:168
        for j=1:8:120
            test_hall_dct2(j:j+7,i:i+7)=D*double(test_hall(j:j+7,i:i+7))*D';
        end
    end
    D=D_calculate(8);
    for i=1:8:168
        for j=1:8:120
            test_hall_idct2(j:j+7,i:i+7)=D'*double(test_hall_dct2(j:j+7,i:i+7))*D;
        end
    end
    test_hall_idct2=double(test_hall_idct2)+ones(size(hall.hall_gray))*128;
    figure('Name','D左侧四列全部置为0');
    imshow(uint8(test_hall_idct2));
%看结果好像不太对,上面是将算子的部分取0，而并非变换后的结果部分取0
%DCT计算完成的系数矩阵部分系数置0
    %Dp右侧四列全部置为0
    D=D_calculate(8);
    for i=1:8:168
        for j=1:8:120
            test_hall_dct2(j:j+7,i:i+7)=D*double(test_hall(j:j+7,i:i+7))*D';
            test_hall_dct2(:,i+4:i+7)=0;
        end
    end
    D=D_calculate(8);
    for i=1:8:168
        for j=1:8:120
            test_hall_idct2(j:j+7,i:i+7)=D'*double(test_hall_dct2(j:j+7,i:i+7))*D;
        end
    end
    test_hall_idct2=double(test_hall_idct2)+ones(size(hall.hall_gray))*128;
    figure('Name','Dp右侧四列全部置为0');
    imshow(uint8(test_hall_idct2));
    %Dp左侧四列全部置为0
    D=D_calculate(8);
    for i=1:8:168
        for j=1:8:120
            test_hall_dct2(j:j+7,i:i+7)=D*double(test_hall(j:j+7,i:i+7))*D';
            test_hall_dct2(:,i:i+3)=0;
        end
    end
    D=D_calculate(8);
    for i=1:8:168
        for j=1:8:120
            test_hall_idct2(j:j+7,i:i+7)=D'*double(test_hall_dct2(j:j+7,i:i+7))*D;
        end
    end
    test_hall_idct2=double(test_hall_idct2)+ones(size(hall.hall_gray))*128;
    figure('Name','Dp左侧四列全部置为0');
    imshow(uint8(test_hall_idct2));

%直接使用dct2库函数,是对整个图像做dct变换
    test_hall_dct2=dct2(double(test_hall));
    %右侧置零
    test_hall_dct2(:,165:168)=0;
    test_hall_idct2=double(idct2(test_hall_dct2))+ones(size(hall.hall_gray))*128;
    figure('Name','对整个图像做DCT变换，右侧置零');
    imshow(uint8(test_hall_idct2));
    %左侧置零
    test_hall_dct2=dct2(double(test_hall));
    test_hall_dct2(:,1:4)=0;
    test_hall_idct2=double(idct2(test_hall_dct2))+ones(size(hall.hall_gray))*128;
    figure('Name','对整个图像做DCT变换，左侧置零');
    imshow(uint8(test_hall_idct2));



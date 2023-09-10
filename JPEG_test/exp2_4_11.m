%解码
close all;
clear;
clc;
global huffman_table;
load('jpegcodes.mat');
load('JpegCoeff.mat');
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
encode=[];
accode=[];
ac_huff_code=[];
i=1;
while i<length(AC_code)
    encode=[encode AC_code(i)];
    if length(encode)==4
            if encode==EOB
                RunSize=[0,0];
                accode=
            end
    end
    if length(encode)==11
            if encode==ZRL
                RunSize=[16,0];
            end
    end
    [temp,~,~]=find(ACTAB(:,3)==length(encode));
    for j=1:length(x)
        ac_huff_code=ACTAB(temp(i),4:length(encode)+3);
        if isequal(ac_huff_code,encode)
            RunSize=[ACTAB(temp(i),1),ACTAB(temp(i),2)];
            break;
        end
    end

    
end
7







      
         






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
        
%
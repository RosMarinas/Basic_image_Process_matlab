%特征提取
function v=feature_extr(x,L)
    [row,column,~]=size(x);
    range=2^(8-L);
    v=zeros(2^(3*L),1);
    x=double(x);
    for i=1:row
        for j=1:column
            ind=[];
            temp=x(i,j,:);
            k=1;
            for k=1:length(temp)
                temp_color=floor(temp(k)/range);
                ind=[ind dec2bin(temp_color,L)];
            end
            ind=bin2dec(ind)+1;
            v(ind)=v(ind)+1;
        end
    end
    v=v/(row*column);
end


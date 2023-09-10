%i-complement 从二进制转换为十进制
%输入数据x为'1010'

function y=icomplement(x)
    x=strrep(x,' ', '');
    if length(x)>0
        if x(1)=='1'
            y=bin2dec(x);
        else
            for i=1:length(x)
                if x(i)=='0' 
                    x(i)='1';
                else 
                    x(i)='0';
                end
            end
            y=-bin2dec(x);
        end
    else 
        y=0;
    end
end

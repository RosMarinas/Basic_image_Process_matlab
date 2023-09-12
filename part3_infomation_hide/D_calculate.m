function D=D_calculate(x)
    D=zeros(x,x);
    for j=1:x
        for i=1:x
            if i~=1
                D(i,j)=cos((2*j-1)*pi*(i-1)/(2*x));
            else
                D(i,j)=1/sqrt(2);
            end
        end
    end
    D=D*sqrt(2)/sqrt(x);
end

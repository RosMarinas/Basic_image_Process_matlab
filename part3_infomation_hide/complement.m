function y=complement(x)
    if x~=0
        length=floor(log2(abs(x)))+1;
    else 
        length=1;
    end
  if (x>=0)
      y=dec2bin(x,12);
  else
      y=dec2bin(x-1,12);
  end
  y=y-'0';
  y=[y((13-length):12)];
  
end
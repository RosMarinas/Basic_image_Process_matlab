%zig-zag扫描方法：
    %1. 循环扫描，未到矩阵边界时行数-1，列数+1,到矩阵边缘时，非边缘的行/列数+1；
    %2. 该过程类似于多项式乘法，自然联想到利用类似卷积的方法实现，不过需要根据奇偶性改变数组顺序；
    %3. 利用hash的方法，将一个二维矩阵直接映射为一个一维矩阵，在使用时直接利用hash索引即可
    
    %已知matlab可以以矩阵为参数，使一个矩阵以参数矩阵的方式进行重新排列
    %因此这里采用了这种方法，预设好参数矩阵，利用参数矩阵将矩阵重新排列
    %再利用matlab的reshape函数，将二维矩阵转换为一维向量
    %具体实现过程见zig_zag.m，这里给出一个zigzag扫描示例
    test=magic(8);
    out_1=zig_zag(test);
    out_2=izig_zag(out_1);

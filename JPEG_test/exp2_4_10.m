% 定义一个函数，例如，计算平方
squareFunction = @(x) x.^2;

% 创建一个示例矩阵
matrix = [1, 2, 3; 4, 5, 6; 7, 8, 9];

% 使用 arrayfun 将函数应用于矩阵的每个元素
result = arrayfun(squareFunction, matrix);

% 显示结果
disp(result);

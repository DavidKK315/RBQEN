function restored_image = ARBQENrestore(type,original_image_path,lambda1,lambda2,opts,beta)
    % 读取原始图像
    RGB = imread(original_image_path);

% 初始化四元数矩阵，大小与图像大小相同
% 四元数的实部为0，虚部为RGB值
quatMatrix = zeros(size(RGB, 1), size(RGB, 2), 4);

% 遍历每个像素
for i = 1:size(RGB, 1)
    for j = 1:size(RGB, 2)
        % 提取RGB值
        r = RGB(i, j, 1);
        g = RGB(i, j, 2);
        b = RGB(i, j, 3);
        
        
        % 将RGB值赋给四元数的虚部
        quatMatrix(i, j, 1) = 0; % 实部为0
        quatMatrix(i, j, 2) = r; % i分量
        quatMatrix(i, j, 3) = g; % j分量
        quatMatrix(i, j, 4) = b; % k分量
    end
end

% 假设 quatMatrix 是四元数矩阵
% 提取四元数分量
P = quatMatrix(:,:,1); % 实数分量
R = quatMatrix(:,:,2); % i分量
G = quatMatrix(:,:,3); % j分量
B = quatMatrix(:,:,4); % k分量

% 创建弱双四元数矩阵的实表示
Z = [P , -R, G , -B;
     R ,  P, B ,  G;
     G , -B, P , -R
     B , G,  R,   P];

% quatMatrix现在包含了每个像素的四元数值

    [m, n] = size(Z); 
    
% 根据输入类型生成不同的模糊矩阵
switch type
case 1    
% 定义高斯函数的参数
sigma = 3.5; % 标准差
r = 4; % 模糊半径，通常取为标准差的几倍
% 定义Toeplitz矩阵的大小原文即有
% 创建一个向量，表示Toeplitz矩阵的第一行
first_row = zeros(1,n);
    for i = -r:r
        % 计算高斯核中的位置偏移
        offset = i + r + 1;
        % 计算高斯值
        first_row(offset) = exp(-(i^2) / (2 * sigma^2)) / (sigma * sqrt(2*pi));
    end

% 归一化高斯核，使得其和为1
first_row = first_row / sum(first_row);

% 使用toeplitz函数生成Toeplitz矩阵
H = toeplitz(first_row);
% 应用模糊核
    g = H*Z;
    
    case 2
% 定义运动模糊的方向和长度
direction = 0; % 水平方向
length = 25; % 模糊长度

% 创建一个向量，表示Toeplitz矩阵的第一行
first_row = zeros(1, n);
for i = 1:length
    if direction == 0 % 水平方向
        first_row(i) = 1 / length;
    end
end

% 归一化运动模糊核，使得其和为1
first_row = first_row / sum(first_row);

% 使用toeplitz函数生成Toeplitz矩阵
H = toeplitz(first_row);
% 应用模糊核
    g = H*Z;
    
case 3 % 均值模糊
     % 定义均值函数的参数
     r = 1; % 模糊半径，通常取为标准差的几倍
    % 创建一个向量，表示Toeplitz矩阵的第一行
    first_row = zeros(1,n);
    for i = -r:r
        % 计算均值核中的位置偏移
        offset = i + r + 1;
        % 计算均值
        first_row(offset) = 1 / (2*r-1);
    end

% 归一化均值核，使得其和为1
first_row = first_row / sum(first_row);
% 使用toeplitz函数生成Toeplitz矩阵
    H = toeplitz(first_row);
    % 应用模糊核
    g = H*Z;

end

    
    % 添加高斯噪声
    SNR = 50; % 信噪比
    g = g + randn(size(g)) .* std(g) / (10^(SNR/10));

    
    % 将图像转化为矩阵方程的右端项
    B = g;
    
    % 将模糊算子转化为矩阵方程的左端项系数矩阵
    A = H;
   
    % 开始计时
    tic;
    
    
    % 调用ADMM框架下的弹性网络方法（系原代码修改版本）
    %原代码见：C. Lu. A Library of ADMM for Sparse and Low-rank Optimization. National University of Singapore, June 2016. https://github.com/canyilu/LibADMM.
    %原代码参考论文：C. Lu, J. Feng, S. Yan, and Z. Lin. A unified alternating direction method of multipliers by majorization minimization. IEEE Transactions on Pattern Analysis and Machine Intelligence, 40(3):527C541, 2018.
    [X,E,obj,err,iter] = aelasticnetR(A,B,lambda1,lambda2,opts,beta);
    
    % 停止计时
    elapsed_time = toc;
    disp(['计算时间: ', num2str(elapsed_time), ' 秒。']);
    
    % 提取实部和虚部
   P = g(1:size(g, 1)/4, 1:size(g, 2)/4);
   R = g(size(g, 1)/4+1:size(g, 2)/2, 1:size(g, 2)/4);
   G = g(size(g, 2)/2+1:size(g, 2)*(3/4), 1:size(g, 2)/4);
   B = g(size(g, 2)*(3/4)+1:end, 1:size(g, 2)/4);
   
   % 提取实部和虚部
   P1 = X(1:size(X, 1)/4, 1:size(X, 2)/4);
   R1 = X(size(X, 1)/4+1:size(X, 2)/2, 1:size(X, 2)/4);
   G1 = X(size(X, 2)/2+1:size(X, 2)*(3/4), 1:size(X, 2)/4);
   B1 = X(size(X, 2)*(3/4)+1:end, 1:size(X, 2)/4);
   
   % 缩放至0-255
P = mat2gray(P) * 255;
R = mat2gray(R) * 255;
G = mat2gray(G) * 255;
B = mat2gray(B) * 255;

P1 = mat2gray(P1) * 255;
R1 = mat2gray(R1) * 255;
G1 = mat2gray(G1) * 255;
B1 = mat2gray(B1) * 255;

   % 将三个通道组合成一个彩色图像
   % 注意：MATLAB中图像的默认颜色通道顺序是RGB
   colorImage = cat(3, R, G, B);
   I = cat(3, R1, G1, B1);
   
   
    % 显示结果
    figure;
    subplot(3, 1, 1); 
    imshow(uint8(RGB)), title('Original Image');
    subplot(3, 1, 2);
    imshow(uint8(colorImage)), title('Damaged Image');
    subplot(3, 1, 3); % 在一个窗口中按顺序显示三张图片
    imshow(uint8(I)), title('Restored Image using RBQEN');

    
    % 返回恢复后的图像
    restored_image = X;
end
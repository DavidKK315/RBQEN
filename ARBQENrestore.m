function restored_image = ARBQENrestore(type,original_image_path,lambda1,lambda2,opts,beta)
    % ��ȡԭʼͼ��
    RGB = imread(original_image_path);

% ��ʼ����Ԫ�����󣬴�С��ͼ���С��ͬ
% ��Ԫ����ʵ��Ϊ0���鲿ΪRGBֵ
quatMatrix = zeros(size(RGB, 1), size(RGB, 2), 4);

% ����ÿ������
for i = 1:size(RGB, 1)
    for j = 1:size(RGB, 2)
        % ��ȡRGBֵ
        r = RGB(i, j, 1);
        g = RGB(i, j, 2);
        b = RGB(i, j, 3);
        
        
        % ��RGBֵ������Ԫ�����鲿
        quatMatrix(i, j, 1) = 0; % ʵ��Ϊ0
        quatMatrix(i, j, 2) = r; % i����
        quatMatrix(i, j, 3) = g; % j����
        quatMatrix(i, j, 4) = b; % k����
    end
end

% ���� quatMatrix ����Ԫ������
% ��ȡ��Ԫ������
P = quatMatrix(:,:,1); % ʵ������
R = quatMatrix(:,:,2); % i����
G = quatMatrix(:,:,3); % j����
B = quatMatrix(:,:,4); % k����

% ������˫��Ԫ�������ʵ��ʾ
Z = [P , -R, G , -B;
     R ,  P, B ,  G;
     G , -B, P , -R
     B , G,  R,   P];

% quatMatrix���ڰ�����ÿ�����ص���Ԫ��ֵ

    [m, n] = size(Z); 
    
% ���������������ɲ�ͬ��ģ������
switch type
case 1    
% �����˹�����Ĳ���
sigma = 3.5; % ��׼��
r = 4; % ģ���뾶��ͨ��ȡΪ��׼��ļ���
% ����Toeplitz����Ĵ�Сԭ�ļ���
% ����һ����������ʾToeplitz����ĵ�һ��
first_row = zeros(1,n);
    for i = -r:r
        % �����˹���е�λ��ƫ��
        offset = i + r + 1;
        % �����˹ֵ
        first_row(offset) = exp(-(i^2) / (2 * sigma^2)) / (sigma * sqrt(2*pi));
    end

% ��һ����˹�ˣ�ʹ�����Ϊ1
first_row = first_row / sum(first_row);

% ʹ��toeplitz��������Toeplitz����
H = toeplitz(first_row);
% Ӧ��ģ����
    g = H*Z;
    
    case 2
% �����˶�ģ���ķ���ͳ���
direction = 0; % ˮƽ����
length = 25; % ģ������

% ����һ����������ʾToeplitz����ĵ�һ��
first_row = zeros(1, n);
for i = 1:length
    if direction == 0 % ˮƽ����
        first_row(i) = 1 / length;
    end
end

% ��һ���˶�ģ���ˣ�ʹ�����Ϊ1
first_row = first_row / sum(first_row);

% ʹ��toeplitz��������Toeplitz����
H = toeplitz(first_row);
% Ӧ��ģ����
    g = H*Z;
    
case 3 % ��ֵģ��
     % �����ֵ�����Ĳ���
     r = 1; % ģ���뾶��ͨ��ȡΪ��׼��ļ���
    % ����һ����������ʾToeplitz����ĵ�һ��
    first_row = zeros(1,n);
    for i = -r:r
        % �����ֵ���е�λ��ƫ��
        offset = i + r + 1;
        % �����ֵ
        first_row(offset) = 1 / (2*r-1);
    end

% ��һ����ֵ�ˣ�ʹ�����Ϊ1
first_row = first_row / sum(first_row);
% ʹ��toeplitz��������Toeplitz����
    H = toeplitz(first_row);
    % Ӧ��ģ����
    g = H*Z;

end

    
    % ��Ӹ�˹����
    SNR = 50; % �����
    g = g + randn(size(g)) .* std(g) / (10^(SNR/10));

    
    % ��ͼ��ת��Ϊ���󷽳̵��Ҷ���
    B = g;
    
    % ��ģ������ת��Ϊ���󷽳̵������ϵ������
    A = H;
   
    % ��ʼ��ʱ
    tic;
    
    
    % ����ADMM����µĵ������緽����ϵԭ�����޸İ汾��
    %ԭ�������C. Lu. A Library of ADMM for Sparse and Low-rank Optimization. National University of Singapore, June 2016. https://github.com/canyilu/LibADMM.
    %ԭ����ο����ģ�C. Lu, J. Feng, S. Yan, and Z. Lin. A unified alternating direction method of multipliers by majorization minimization. IEEE Transactions on Pattern Analysis and Machine Intelligence, 40(3):527C541, 2018.
    [X,E,obj,err,iter] = aelasticnetR(A,B,lambda1,lambda2,opts,beta);
    
    % ֹͣ��ʱ
    elapsed_time = toc;
    disp(['����ʱ��: ', num2str(elapsed_time), ' �롣']);
    
    % ��ȡʵ�����鲿
   P = g(1:size(g, 1)/4, 1:size(g, 2)/4);
   R = g(size(g, 1)/4+1:size(g, 2)/2, 1:size(g, 2)/4);
   G = g(size(g, 2)/2+1:size(g, 2)*(3/4), 1:size(g, 2)/4);
   B = g(size(g, 2)*(3/4)+1:end, 1:size(g, 2)/4);
   
   % ��ȡʵ�����鲿
   P1 = X(1:size(X, 1)/4, 1:size(X, 2)/4);
   R1 = X(size(X, 1)/4+1:size(X, 2)/2, 1:size(X, 2)/4);
   G1 = X(size(X, 2)/2+1:size(X, 2)*(3/4), 1:size(X, 2)/4);
   B1 = X(size(X, 2)*(3/4)+1:end, 1:size(X, 2)/4);
   
   % ������0-255
P = mat2gray(P) * 255;
R = mat2gray(R) * 255;
G = mat2gray(G) * 255;
B = mat2gray(B) * 255;

P1 = mat2gray(P1) * 255;
R1 = mat2gray(R1) * 255;
G1 = mat2gray(G1) * 255;
B1 = mat2gray(B1) * 255;

   % ������ͨ����ϳ�һ����ɫͼ��
   % ע�⣺MATLAB��ͼ���Ĭ����ɫͨ��˳����RGB
   colorImage = cat(3, R, G, B);
   I = cat(3, R1, G1, B1);
   
   
    % ��ʾ���
    figure;
    subplot(3, 1, 1); 
    imshow(uint8(RGB)), title('Original Image');
    subplot(3, 1, 2);
    imshow(uint8(colorImage)), title('Damaged Image');
    subplot(3, 1, 3); % ��һ�������а�˳����ʾ����ͼƬ
    imshow(uint8(I)), title('Restored Image using RBQEN');

    
    % ���ػָ����ͼ��
    restored_image = X;
end
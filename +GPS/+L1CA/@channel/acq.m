function acqResult = acq(obj, dataI, dataQ)
% ���������ź�
% acqResult:������,[����λ,�ز�Ƶ��,��ֵ��ֵ],�޽��Ϊ[]
% dataI,dataQ:ԭʼ����,������

fs = obj.sampleFreq; %����Ƶ��,Hz
N = obj.acqN; %�����������
M = obj.acqM; %����Ƶ�ʸ���

% ȡ������������������,��Ϊ���ܴ��ڵ������ĵķ�ת������ط��С
signal1 =     dataI(1:N) + dataQ(1:N)*1i;
signal2 = dataI(N+1:end) + dataQ(N+1:end)*1i;

% ��������洢�ռ�
n = fs*0.001; %һ��C/A�����ڲ�������
result1 = zeros(M,n); %����������,�����ز�Ƶ��,��������λ
result2 = zeros(M,n);

% ����ÿ��Ƶ��
t = -2i*pi/fs * (0:N-1);
for k=1:M
    carrier = exp(obj.acqFreq(k)*t); %���ظ��ز�,��Ƶ��
    x = signal1.*carrier;
    X = fft(x);
    Y = conj(X).*obj.CODE;
    y = abs(ifft(Y));
    result1(k,:) = y(1:n); %ֻȡһ��C/A�����ڵ���,����Ķ����ظ���
    x = signal2.*carrier;
    X = fft(x);
    Y = conj(X).*obj.CODE;
    y = abs(ifft(Y));
    result2(k,:) = y(1:n);
end

% ѡȡֵ�����������
[corrValue1, codePhase1] = max(result1,[],2); %���������ֵ,���Ϊ��
[corrValue2, codePhase2] = max(result2,[],2);
if max(corrValue1)>max(corrValue2)
    corrValue = corrValue1;
    codePhase = codePhase1;
else
    corrValue = corrValue2;
    codePhase = codePhase2;
end

% Ѱ����ط�
[peak1, index] = max(corrValue); %����
corrValue(mod(index+(-3:3)-1,M)+1) = 0; %�ų��������ط���Χ�ĵ�
peak2 = max(corrValue); %�ڶ����

% ������
peakRatio = peak1 / peak2; %��߷���ڶ����ı�ֵ
if peakRatio>obj.acqThreshold
    acqResult = [codePhase(index), obj.acqFreq(index), peakRatio];
else
    acqResult = [];
end

end
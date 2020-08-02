function acqResult = acq(obj, dataI, dataQ)
% ���������ź�
% acqResult:������,[����λ,�ز�Ƶ��,��ֵ��ֵ],�޽��Ϊ[]
% dataI,dataQ:ԭʼ����,������

fs = obj.sampleFreq; %����Ƶ��,Hz
N = obj.acqN; %�����������
M = obj.acqM; %����Ƶ�ʸ���

% ����ת��Ϊ����
signal = dataI + dataQ*1i;

% ��������洢�ռ�
n = fs*0.01; %һ��α�����ڲ�������
result = zeros(M,n);

% ����ÿ��Ƶ��
t = -2i*pi/fs * (0:N-1);
for k=1:M
    carrier = exp(obj.acqFreq(k)*t); %���ظ��ز�,��Ƶ��
    x = signal.*carrier;
    X = fft(x);
    Y = conj(X).*obj.CODE;
    y = abs(ifft(Y));
    result(k,:) = y(1:n); %ֻȡǰn��
end

% Ѱ����ط�
[corrValue, codePhase] = max(result,[],2); %���������ֵ,���Ϊ��
[peak1, index] = max(corrValue); %����
corrValue(mod(index+(-5:5)-1,M)+1) = 0; %�ų��������ط���Χ�ĵ�
peak2 = max(corrValue); %�ڶ����

% ������
peakRatio = peak1 / peak2; %��߷���ڶ����ı�ֵ
if peakRatio>obj.acqThreshold
    acqResult = [codePhase(index), obj.acqFreq(index), peakRatio];
else
    acqResult = [];
end

end
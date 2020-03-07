function acqResult = acquisition(filename, fs, sampleOffset, acqConf)
% ����GPS����L1 C/A�źŵĲ���,��ͼ
% filename:�ļ���
% fs:����Ƶ��,Hz
% sampleOffset:����ǰ���ٸ�������
% acqConf:�����������
% acqResult:������,[����λ,�ز�Ƶ��,��ֵ��ֵ]
% �ο�GPS.L1CA.channel.acq

N = fs/1000 * acqConf.time; %�����������
acqFreq = -acqConf.freqMax:(fs/N/2):acqConf.freqMax; %����Ƶ�ʷ�Χ
M = length(acqFreq); %����Ƶ�ʸ���

% ������,ȡ������������������
fileID = fopen(filename, 'r');
fseek(fileID, round(sampleOffset*4), 'bof');
if int64(ftell(fileID))~=int64(sampleOffset*4)
    error('Sample offset error!')
end
signal = double(fread(fileID, [2,N], 'int16'));
signal1 = signal(1,:) + signal(2,:)*1i; %���ź�
signal = double(fread(fileID, [2,N], 'int16'));
signal2 = signal(1,:) + signal(2,:)*1i;
fclose(fileID);

% ��������洢�ռ�
n = fs*0.001; %һ��C/A�����ڲ�������
result1 = zeros(M,n); %����������,�����ز�Ƶ��,��������λ
result2 = zeros(M,n);

% ��ͼ����
[Xg, Yg] = meshgrid(1:n, acqFreq);

% ����
acqResult = NaN(32,3);
codeIndex = mod(floor((0:N-1)*1.023e6/fs),1023) + 1; %C/A�����������
t = -2i*pi * (0:N-1)/fs; %�����ز�ʱ�õ�ʱ������,��Ƶ��,������λ
for PRN=1:32
    %----���ɱ������FFT
    CAcode = GPS.L1CA.codeGene(PRN);
    CODE = fft(CAcode(codeIndex));
    %----����ÿ��Ƶ��
    for k=1:M
        carrier = exp(acqFreq(k)*t);
        x = signal1.*carrier;
        X = fft(x);
        Y = conj(X).*CODE;
        y = abs(ifft(Y));
        result1(k,:) = y(1:n); %ֻȡһ��C/A�����ڵ���,����Ķ����ظ���
        x = signal2.*carrier;
        X = fft(x);
        Y = conj(X).*CODE;
        y = abs(ifft(Y));
        result2(k,:) = y(1:n);
    end
    %----ѡȡֵ�����������
    [corrValue1, codePhase1] = max(result1,[],2); %���������ֵ,���Ϊ��
    [corrValue2, codePhase2] = max(result2,[],2);
    if max(corrValue1)>max(corrValue2)
        corrValue = corrValue1;
        codePhase = codePhase1;
        result = result1; %������ͼ
    else
        corrValue = corrValue2;
        codePhase = codePhase2;
        result = result2;
    end
    %----Ѱ����ط�
    [peak1, index] = max(corrValue); %����
    corrValue(mod(index+(-3:3)-1,M)+1) = 0; %�ų��������ط���Χ�ĵ�
    peak2 = max(corrValue); %�ڶ����
    %----���������,��ͼ
    peakRatio = peak1 / peak2; %��߷���ڶ����ı�ֵ
    if peakRatio>acqConf.threshold
        acqResult(PRN,:) = [codePhase(index), acqFreq(index), peakRatio];
        figure
        surf(Xg,Yg,result)
        title(['PRN ',num2str(PRN),', ',num2str(peakRatio)])
    end
end

end
function acqResult = acquisition(filename, fs, sampleOffset, acqConf)
% ���б�������B1C�źŵĲ���,��ͼ
% filename:�ļ���
% fs:����Ƶ��,Hz
% sampleOffset:����ǰ���ٸ�������
% acqConf:�����������
% acqResult:������,[���Ǻ�,����λ,�ز�Ƶ��]

%�������Ų���B1C�źŵ������б�
svList = [19:30,32:46]; %��27��

N = fs/100; %һ��������(10ms)��������
Ns = 2*N; %һ�β����������,��Ҫ����������
acqFreq = -acqConf.freqMax:(fs/N/2):acqConf.freqMax; %����Ƶ�ʷ�Χ
M = length(acqFreq); %����Ƶ�ʸ���

% ������,����,20ms
fileID = fopen(filename, 'r');
fseek(fileID, round(sampleOffset*4), 'bof');
if int64(ftell(fileID))~=int64(sampleOffset*4)
    error('Sample offset error!')
end
signal = double(fread(fileID, [2,Ns], 'int16'));
signal = signal(1,:) + signal(2,:)*1i; %���ź�
fclose(fileID);

% ��������洢�ռ�
result = zeros(M,N); %����������,�����ز�Ƶ��,��������λ

% ����
acqResult = NaN(length(svList),2);
codeIndex = floor((0:N-1)*1.023e6*2/fs) + 1; %���������������,��Ϊ�������ز�,�൱����Ƶ�ʳ�2
t = -2i*pi * (0:Ns-1)/fs; %�����ز�ʱ�õ�ʱ������,��Ƶ��,������λ
for PRN=svList
    %----���ɰ������ز��ı�����,����FFT
%     B1Ccode = BDS.B1C.codeGene_data(PRN); %��������ͨ��
    B1Ccode = BDS.B1C.codeGene_pilot(PRN); %����Ƶͨ��
    B1Ccode = reshape([B1Ccode;-B1Ccode],10230*2,1)'; %�����ز�,������
    codes = B1Ccode(codeIndex);
    code = [zeros(1,N), codes]; %ǰ�油��
    CODE = fft(code);
    %----����ÿ��Ƶ��
    for k=1:M
        carrier = exp(acqFreq(k)*t);
        x = signal.*carrier;
        X = fft(x);
        Y = conj(X).*CODE;
        y = abs(ifft(Y));
        result(k,:) = y(1:N); %ֻȡǰN��
    end
    %----Ѱ����ط�
    [corrValue, codePhase] = max(result,[],2); %���������ֵ,���Ϊ��
    [peak1, index] = max(corrValue); %����
    corrValue(mod(index+(-5:5)-1,M)+1) = 0; %�ų��������ط���Χ�ĵ�
    peak2 = max(corrValue); %�ڶ����
    %----��� ������,��ͼ
    peakRatio = peak1 / peak2; %��߷���ڶ����ı�ֵ
    if peakRatio>acqConf.threshold
        % �沶����
        ki = find(svList==PRN,1);
        acqResult(ki,1) = codePhase(index); %����λ,�����һ��������ģ����󲶻�����λ
        acqResult(ki,2) = acqFreq(index); %�ز�Ƶ��
        % ��ͼ
        figure
        subplot(2,1,1) %����λΪ����,�Ŵ���Կ�������ط�
        plot(result(index,:)) %result����
        grid on
        xlabel('code phase')
        title(['PRN ',num2str(PRN),', ',num2str(peakRatio)])
        subplot(2,1,2) %�ز�Ƶ��Ϊ����
        plot(acqFreq, result(:,codePhase(index))') %result����
        grid on
        xlabel('carrier frequency')
        drawnow
    end
end

acqResult = [svList', acqResult]; %��һ��������Ǳ��

end
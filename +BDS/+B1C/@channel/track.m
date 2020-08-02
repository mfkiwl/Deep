function track(obj, dataI, dataQ, deltaFreq)
% ���������ź�
% dataI,dataQ:ԭʼ����,������
% deltaFreq:���ջ�ʱ��Ƶ�����,������,�ӿ�Ϊ��
% ��ΪB1C����ʱ��õ��ز�Ƶ�ʾ��ȸ�,���Կ�ʼʱ����Ҫ��Ƶ��ǣ��

pi2 = 2*pi;

% �洢���ٽ��(���θ��ٿ�ʼʱ������)
obj.ns = obj.ns+1; %ָ��ǰ�洢��
n = obj.ns;
obj.storage.dataIndex(n)    = obj.dataIndex;
obj.storage.remCodePhase(n) = obj.remCodePhase;
obj.storage.codeFreq(n)     = obj.codeFreq;
obj.storage.remCarrPhase(n) = obj.remCarrPhase;
obj.storage.carrFreq(n)     = obj.carrFreq;
obj.storage.carrNco(n)      = obj.carrNco;
obj.storage.carrAcc(n)      = obj.carrAccS + obj.carrAccR;

% ָ���´θ��µĿ�ʼ��
obj.dataIndex = obj.dataIndex + obj.trackBlockSize;

% У������Ƶ��
fs = obj.sampleFreq * (1+deltaFreq);

% ʱ������
dts = 1/fs; %����ʱ����
t = (0:obj.trackBlockSize-1) * dts;
te = obj.trackBlockSize * dts;

% �����ز�
theta = (obj.remCarrPhase + obj.carrNco*t) * pi2;
carr_cos = cos(theta);
carr_sin = sin(theta);
theta_next = obj.remCarrPhase + obj.carrNco*te;
obj.remCarrPhase = mod(theta_next, 1); %ʣ���ز���λ,��

% ������
tcode = obj.remCodePhase + obj.codeNco*t + 2; %��2��֤���ͺ���ʱ����1
codeE = obj.codePilot(floor(tcode+0.3)); %��ǰ��
codeP = obj.codePilot(floor(tcode));     %��ʱ��
codeL = obj.codePilot(floor(tcode-0.3)); %�ͺ���
obj.remCodePhase = mod(obj.remCodePhase + obj.codeNco*te, 20460); %ʣ������λ,��Ƭ

% ԭʼ���ݳ��ز�
signalI = dataI.*carr_cos + dataQ.*carr_sin; %�˸��ز�
signalQ = dataQ.*carr_cos - dataI.*carr_sin;

% ��·����
I_E = signalI * codeE;
Q_E = signalQ * codeE;
I_P = signalI * codeP;
Q_P = signalQ * codeP;
I_L = signalI * codeL;
Q_L = signalQ * codeL;

% ���ݷ�������ֵ
codeDP = obj.codeData(floor(tcode));
obj.Id = -signalQ * codeDP; %����Ƶ������x�������غ�ʱ,���ݷ�����y�ᷴ��
obj.Ip = I_P;

% �������
S_E = sqrt(I_E^2+Q_E^2);
S_L = sqrt(I_L^2+Q_L^2);
codeError = (11/30) * (S_E-S_L)/(S_E+S_L); %ʵ�����������,��λ:��Ƭ,һ�����ز���һ����Ƭ

% �ز�������
if obj.carrDiscFlag==0
    carrError = atan(Q_P/I_P) / pi2; %ʵ����λ��������λ,��λ:��
else
    s = obj.codeSub(obj.subPhase); %�������
    carrError = atan2(Q_P*s,I_P*s) / pi2; %�����޷����м�����
end

% ��Ƶ��
yc = obj.I*I_P + obj.Q*Q_P; %I0*I1+Q0*Q1
ys = obj.I*Q_P - obj.Q*I_P; %I0*Q1-Q0*I1
freqError = atan(ys/yc)/obj.timeIntS / pi2; %ʵ��Ƶ�ʼ�����Ƶ��,��λ:Hz
obj.I = I_P;
obj.Q = Q_P;

% �ز�����
switch obj.carrMode
    case 1 %���໷
        order2PLL(carrError);
end

% �����
switch obj.codeMode
    case 1 %�ӳ�������
        order2DLL(codeError);
end

% ����Ŀ������λ,��Ƶ������λ,α������ʱ��
if obj.codeTarget==20460
    obj.codeTarget = obj.timeIntMs * 2046;
    obj.subPhase = mod(obj.subPhase,1800) + 1; %��Ƶ������λ��1(ֻ��֡ͬ����ȷ���˵�Ƶ������λ��������)
    obj.tc0 = obj.tc0 + 10; %һ��α������10ms
else
    obj.codeTarget = obj.codeTarget + obj.timeIntMs*2046; %����Ŀ������λ
end

% ������һ���ݿ�λ��
obj.trackDataTail = obj.trackDataHead + 1;
if obj.trackDataTail>obj.buffSize
    obj.trackDataTail = 1;
end
obj.trackBlockSize = ceil((obj.codeTarget-obj.remCodePhase)/obj.codeNco*fs);
obj.trackDataHead = obj.trackDataTail + obj.trackBlockSize - 1;
if obj.trackDataHead>obj.buffSize
    obj.trackDataHead = obj.trackDataHead - obj.buffSize;
end

% �洢���ٽ��(���θ��ٲ���������)
obj.storage.I_Q(n,:) = [I_P, I_E, I_L, Q_P, Q_E, Q_L, obj.Id, obj.Ip];
obj.storage.disc(n,:) = [codeError/2, carrError, freqError]; %����λ������2,�����������λ���

    %% Ƶ��ǣ��
    
    %% �������໷
    function order2PLL(carrError)
        % PLL2 = [K1, K2]
        carrAcc = obj.carrAccS + obj.carrAccR;
        obj.carrFreq = obj.carrFreq + obj.PLL2(2)*carrError + carrAcc*obj.timeIntS;
        obj.carrNco = obj.carrFreq + obj.PLL2(1)*carrError;
    end
    
    %% �����ӳ�������
    function order2DLL(codeError)
        % DLL2 = [K1, K2]
        obj.codeFreq = obj.codeFreq + obj.DLL2(2)*codeError;
        obj.codeNco = obj.codeFreq + obj.DLL2(1)*codeError;
    end

end
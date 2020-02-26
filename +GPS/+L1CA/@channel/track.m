function track(obj, dataI, dataQ, deltaFreq)
% ���������ź�
% dataI,dataQ:ԭʼ����,������
% deltaFreq:���ջ�ʱ��Ƶ�����,������,�ӿ�Ϊ��

pi2 = 2*pi;

% �洢���ٽ��(���θ��ٿ�ʼʱ������)
obj.ns = obj.ns+1; %ָ��ǰ�洢��
n = obj.ns;
obj.storage.dataIndex(n)    = obj.dataIndex;
obj.storage.remCodePhase(n) = obj.remCodePhase;
obj.storage.codeFreq(n)     = obj.codeFreq;
obj.storage.remCarrPhase(n) = obj.remCarrPhase;
obj.storage.carrFreq(n)     = obj.carrFreq;

% ָ���´θ��µĿ�ʼ��
obj.dataIndex = obj.dataIndex + obj.trackBlockSize;

% У������Ƶ��
fs = obj.sampleFreq * (1+deltaFreq);

% ʱ������
t = (0:obj.trackBlockSize-1) / fs;
te = obj.trackBlockSize / fs;

% �����ز�
theta = (obj.remCarrPhase + obj.carrNco*t) * pi2; %��2��Ϊ��������piΪ��λ�����Ǻ���
carr_cos = cos(theta);
carr_sin = sin(theta);
theta_next = obj.remCarrPhase + obj.carrNco*te;
obj.remCarrPhase = mod(theta_next, 1); %ʣ���ز���λ,��

% ������
tcode = obj.remCodePhase + obj.codeNco*t + 2; %��2��֤���ͺ���ʱ����1
codeE = obj.code(floor(tcode+0.3)); %��ǰ��
codeP = obj.code(floor(tcode));     %��ʱ��
codeL = obj.code(floor(tcode-0.3)); %�ͺ���
obj.remCodePhase = obj.remCodePhase + obj.codeNco*te - obj.codeInt; %ʣ���ز���λ,��

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

% �������
S_E = sqrt(I_E^2+Q_E^2);
S_L = sqrt(I_L^2+Q_L^2);
codeError = 0.7 * (S_E-S_L)/(S_E+S_L); %ʵ�����������,��λ:��Ƭ
% 0.5--0.5,0.4--0.6,0.3--0.7,0.25--0.75

% �ز�������
carrError = atan(Q_P/I_P) / pi2; %ʵ����λ��������λ,��λ:��

% ��Ƶ��
yc = obj.I*I_P + obj.Q*Q_P; %I0*I1+Q0*Q1
ys = obj.I*Q_P - obj.Q*I_P; %I0*Q1-Q0*I1
freqError = atan(ys/yc)/obj.timeIntS / pi2; %ʵ��Ƶ�ʼ�����Ƶ��,��λ:Hz
obj.I = I_P;
obj.Q = Q_P;

% �ز�����
switch obj.carrMode
    case 0
    case 1 %Ƶ��ǣ��
        freqPull(freqError);
    case 2 %���໷
        order2PLL(carrError);
end

% �����
switch obj.codeMode
    case 0
    case 1 %�ӳ�������
        order2DLL(codeError);
end

% ����α��ʱ��
obj.tc0 = obj.tc0 + obj.timeIntMs;

% ������һ���ݿ�λ��
obj.trackDataTail = obj.trackDataHead + 1;
if obj.trackDataTail>obj.buffSize
    obj.trackDataTail = 1;
end
obj.trackBlockSize = ceil((obj.codeInt-obj.remCodePhase)/obj.codeNco*fs);
obj.trackDataHead = obj.trackDataTail + obj.trackBlockSize - 1;
if obj.trackDataHead>obj.buffSize
    obj.trackDataHead = obj.trackDataHead - obj.buffSize;
end

% �洢���ٽ��(���θ��ٲ���������)
obj.storage.I_Q(n,:) = [I_P, I_E, I_L, Q_P, Q_E, Q_L];
obj.storage.disc(n,:) = [codeError, carrError, freqError];

    %% Ƶ��ǣ��
    function freqPull(freqError)
        % ����һ��ʱ����Ƶ��,��ʱ����Զ��������໷
        obj.FLL.Int = obj.FLL.Int + obj.FLL.K*freqError;
        obj.carrNco = obj.FLL.Int;
        obj.carrFreq = obj.FLL.Int;
        obj.FLL.cnt = obj.FLL.cnt + 1; %����
        if obj.FLL.cnt==200
            obj.FLL.cnt = 0;
            obj.PLL.Int = obj.FLL.Int; %���໷��������ֵ
            obj.carrMode = 2; %ת�����໷
            log_str = sprintf('Start PLL tracking at %.8fs', obj.dataIndex/obj.sampleFreq);
            obj.log = [obj.log; string(log_str)];
        end
    end

    %% �������໷
    function order2PLL(carrError)
        obj.PLL.Int = obj.PLL.Int + obj.PLL.K2*carrError;
        obj.carrNco = obj.PLL.Int + obj.PLL.K1*carrError;
        obj.carrFreq = obj.PLL.Int;
    end

    %% �����ӳ�������
    function order2DLL(codeError)
        obj.DLL.Int = obj.DLL.Int + obj.DLL.K2*codeError;
        obj.codeNco = obj.DLL.Int + obj.DLL.K1*codeError;
        obj.codeFreq = obj.DLL.Int;
    end

end
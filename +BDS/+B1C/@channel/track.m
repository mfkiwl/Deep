function track(obj, dataI, dataQ)
% ���������ź�,ÿ1msִ��һ��
% dataI,dataQ:ԭʼ����,������
% ��ΪB1C����ʱ��õ��ز�Ƶ�ʾ��ȸ�,���Կ�ʼʱ����Ҫ��Ƶ��ǣ��

pi2 = 2*pi;

% �洢�к�
obj.ns = obj.ns+1; %ָ��ǰ�洢��
n = obj.ns;

% ָ���´θ��µĿ�ʼ��
obj.dataIndex = obj.dataIndex + obj.trackBlockSize;

% ʱ������
t = obj.Tseq(1:obj.trackBlockSize);
te = obj.Tseq(obj.trackBlockSize+1);

% �����ز�
theta = (obj.remCarrPhase + obj.carrNco*t) * pi2;
carr_cos = cos(theta);
carr_sin = sin(theta);
theta_next = obj.remCarrPhase + obj.carrNco*te;
obj.remCarrPhase = mod(theta_next, 1); %ʣ���ز���λ,��

% ������
tcode = obj.remCodePhase + obj.codeNco*t + 2; %��2��֤���ͺ���ʱ����1
index = floor(tcode);
codeE = obj.codePilot(floor(tcode+0.3)); %��ǰ��
codeP = obj.codePilot(index);            %��ʱ��
codeL = obj.codePilot(floor(tcode-0.3)); %�ͺ���
obj.remCodePhase = obj.remCodePhase + obj.codeNco*te; %ʣ������λ,��Ƭ
obj.remCodePhase = mod(obj.remCodePhase+1,20460)-1; %��ֹʣ������λ��С��20460,������trackBlockSizeʱ���ָ���

% ԭʼ���ݳ��ز�
signalI = dataI.*carr_cos + dataQ.*carr_sin; %�˸��ز�
signalQ = dataQ.*carr_cos - dataI.*carr_sin;

% ��·����
IE_1ms = signalI * codeE;
QE_1ms = signalQ * codeE;
IP_1ms = signalI * codeP;
QP_1ms = signalQ * codeP;
IL_1ms = signalI * codeL;
QL_1ms = signalQ * codeL;
I_Q_1ms = [IP_1ms, IE_1ms, IL_1ms, QP_1ms, QE_1ms, QL_1ms];
if obj.carrDiscFlag==1 %ȷ��������λ���������ֵ�ķ���
    I_Q_1ms = I_Q_1ms * obj.codeSub(obj.subPhase);
end

% ���ݷ�������ֵ
codeDP = obj.codeData(index);
Id = -signalQ * codeDP; %����Ƶ������x�������غ�ʱ,���ݷ�����y�ᷴ��

% ����ۼ�
if obj.coherentCnt==0
    obj.I0 = obj.I_Q(1); %��¼�ϴ�I/Qֵ
    obj.Q0 = obj.I_Q(4);
    obj.I_Q = I_Q_1ms; %�״�ֱ�Ӹ�ֵ
else
    obj.I_Q = obj.I_Q + I_Q_1ms;
end
obj.coherentCnt = obj.coherentCnt + 1;

% ��������ز���Ƶ��(���ز����ٶ�����,������Ӧ������ʱ������)
dCarrFreq = (obj.carrAccS+obj.carrAccR) * 0.001; %�ز�Ƶ������
obj.carrFreq = obj.carrFreq + dCarrFreq;
obj.carrNco = obj.carrNco + dCarrFreq;
dCodeFreq = dCarrFreq / 770; %��Ƶ������
obj.codeFreq = obj.codeFreq + dCodeFreq;
obj.codeNco = obj.codeNco + dCodeFreq;

% ��ɻ���ʱ�䵽��
if obj.coherentCnt==obj.coherentN
    obj.coherentCnt = 0; %�����
    
    % ��ȡ��·I/Q����
    I_P = obj.I_Q(1);
    I_E = obj.I_Q(2);
    I_L = obj.I_Q(3);
    Q_P = obj.I_Q(4);
    Q_E = obj.I_Q(5);
    Q_L = obj.I_Q(6);
    
    % �������
    S_E = sqrt(I_E^2+Q_E^2);
    S_L = sqrt(I_L^2+Q_L^2);
    codeError = (11/30) * (S_E-S_L)/(S_E+S_L); %ʵ�����������,��λ:��Ƭ,һ�����ز���һ����Ƭ
    
    % �ز�������
    if obj.carrDiscFlag==0
        carrError = atan(Q_P/I_P) / pi2; %ʵ����λ��������λ,��λ:��
    else
        carrError = atan2(Q_P,I_P) / pi2; %�����޷����м�����
    end
    
    % ��Ƶ��
    yc = obj.I0*I_P + obj.Q0*Q_P; %I0*I1+Q0*Q1
    ys = obj.I0*Q_P - obj.Q0*I_P; %I0*Q1-Q0*I1
    freqError = atan(ys/yc)/obj.coherentTime / pi2; %ʵ��Ƶ�ʼ�����Ƶ��,��λ:Hz
    
    % �洢���������
    obj.storage.disc(n,:) = [codeError/2, carrError, freqError]; %����λ������2,�����������λ���
    obj.codeDiscBuffPtr = obj.codeDiscBuffPtr + 1;
    obj.codeDiscBuff(obj.codeDiscBuffPtr) = codeError/2; %������λ���
    if obj.codeDiscBuffPtr==200
        obj.codeDiscBuffPtr = 0;
    end
    
    % �ز�����
    switch obj.carrMode
        case 2 %�������໷
            order2PLL(carrError);
        case 3 %ʸ���������໷
            vectorPLL2(carrError);
    end
    
    % �����
    switch obj.codeMode
        case 1 %�����ӳ�������
            order2DLL(codeError);
        case 2 %�뿪��
            openDLL;
    end
end

% ����Ŀ������λ,��Ƶ������λ,α������ʱ��
if obj.codeTarget==20460
    obj.codeTarget = 2046;
    obj.subPhase = mod(obj.subPhase,1800) + 1; %��Ƶ������λ��1(ֻ��֡ͬ����ȷ���˵�Ƶ������λ��������)
    obj.tc0 = obj.tc0 + 10; %һ��α������10ms
else
    obj.codeTarget = obj.codeTarget + 2046; %����Ŀ������λ
end

% ������һ���ݿ�λ��
obj.trackDataTail = obj.trackDataHead + 1;
if obj.trackDataTail>obj.buffSize
    obj.trackDataTail = 1;
end
obj.trackBlockSize = ceil((obj.codeTarget-obj.remCodePhase)/obj.codeNco*obj.sampleFreq);
obj.trackDataHead = obj.trackDataTail + obj.trackBlockSize - 1;
if obj.trackDataHead>obj.buffSize
    obj.trackDataHead = obj.trackDataHead - obj.buffSize;
end

% �ۻ�����,���������
obj.trackCnt = obj.trackCnt + 1;
if obj.bitSyncFlag==1 %��ɱ���ͬ��
    obj.IpBuff(obj.trackCnt) = IP_1ms;
    obj.QpBuff(obj.trackCnt) = QP_1ms;
    obj.IdBuff(obj.trackCnt) = Id;
    if obj.trackCnt==10 %������1������
        obj.trackCnt = 0; %�������
        %----��¼���ر߽��־
        obj.storage.bitFlag(n) = obj.msgStage; %���ؽ�����λ��
        %----���������
        obj.CN0 = obj.CNR.cal(obj.IpBuff, obj.QpBuff);
        %----��������ʱ��
        obj.adjust_coherentTime(2);
        %----������������
        obj.varValue = obj.varCoef / 10^(obj.CN0/10);
        %----�ź�ʧ������
        if obj.CN0<18
            obj.lossCnt = obj.lossCnt + 1;
        else
            obj.lossCnt = 0;
        end
        %----��ʱ��ʧ���ر�ͨ��(ʸ������ʱ����)
        if obj.lossCnt>5 && obj.state~=3
            obj.state = 0;
            obj.ns = obj.ns + 1; %���ݴ洢��һ��,�൱�ڼ�һ����ϵ�
            log_str = sprintf('***Loss of lock at %.8fs', obj.dataIndex/obj.sampleFreq);
            obj.log = [obj.log; string(log_str)];
        end
    end %end ������һ������
end

% �洢���ٽ��
obj.storage.dataIndex(n) = obj.dataIndex;
obj.storage.remCodePhase(n) = obj.remCodePhase;
obj.storage.codeFreq(n) = obj.codeFreq;
obj.storage.remCarrPhase(n) = obj.remCarrPhase;
obj.storage.carrFreq(n) = obj.carrFreq;
obj.storage.carrNco(n) = obj.carrNco;
obj.storage.carrAcc(n) = obj.carrAccS + obj.carrAccR;
obj.storage.I_Q(n,:) = [IP_1ms, IE_1ms, IL_1ms, QP_1ms, QE_1ms, QL_1ms, Id, IP_1ms];
% obj.storage.I_Q(n,:) = [I_Q_1ms, Id, IP_1ms]; %�������ݵ�
obj.storage.CN0(n) = obj.CN0;

    %% �������໷
    function order2PLL(carrError)
        % PLL2 = [K1, K2, Bn]
        obj.carrFreq = obj.carrFreq + obj.PLL2(2)*carrError; %���������ز�Ƶ�ʹ���ֵ
        %----��Ƶ����
%         obj.carrNco = obj.carrFreq + obj.PLL2(1)*carrError;
        %----ֱ�ӵ���
        obj.carrNco = obj.carrFreq;
        obj.remCarrPhase = obj.remCarrPhase + obj.PLL2(1)*carrError*obj.coherentTime;
    end

    %% ʸ���������໷
    function vectorPLL2(carrError)
        % PLL2 = [K1, K2, Bn]
        % ����Ƶ�ʿ����׻�·����,����Ƶ�ʿ��ⲿ����
        dt = obj.coherentTime; %ʱ����
        df = obj.carrFreq - obj.carrNco;
        dp = carrError - df*dt;
        obj.remCarrPhase = obj.remCarrPhase + df*dt + obj.PLL2(1)*dt*dp; %alpha=K1*dt
        obj.carrFreq = obj.carrFreq + obj.PLL2(2)*dp; %beta=K2
        if obj.CN0<37 %����ǿ�źŲ����ز�Ƶ�ʽ��й���,���ź�תΪǿ�ź��൱���������໷
            obj.carrFreq = obj.carrNco;
        end
    end

    %% �����ӳ�������
    function order2DLL(codeError)
        % DLL2 = [K1, K2, Bn]
        obj.codeFreq = obj.codeFreq + obj.DLL2(2)*codeError;
        %----��Ƶ����
%         obj.codeNco = obj.codeFreq + obj.DLL2(1)*codeError;
        %----ֱ�ӵ���
        obj.codeNco = obj.codeFreq;
        obj.remCodePhase = obj.remCodePhase + obj.DLL2(1)*codeError*obj.coherentTime;
    end

    %% �뿪��
    function openDLL
        obj.codeNco = (1.023e6 + obj.carrFreq/1540) * 2; %��Ϊ�����ز�,Ҫ��2
        obj.codeFreq = obj.codeNco;
    end

end
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
obj.remCodePhase = obj.remCodePhase + obj.codeNco*te - obj.codeInt; %ʣ������λ,��Ƭ

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
    case 1 %Ƶ��ǣ��
        freqPull(freqError);
    case 2 %���໷
        order2PLL(carrError);
    case 3 %��������໷
        deepPLL(carrError);
end

% �����
switch obj.codeMode
    case 1 %�ӳ�������
        order2DLL(codeError);
    case 2 %�뿪��
        openDLL(deltaFreq);
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
%     function freqPull(freqError)
%         % ����һ��ʱ����Ƶ��,��ʱ����Զ��������໷
%         % FLLp = [K, Int, cnt]
%         obj.FLLp(2) = obj.FLLp(2) + obj.FLLp(1)*freqError;
%         obj.carrNco = obj.FLLp(2);
%         obj.carrFreq = obj.FLLp(2);
%         obj.FLLp(3) = obj.FLLp(3) + 1; %����
%         if obj.FLLp(3)==200
%             obj.FLLp(3) = 0;
%             obj.PLL2(3) = obj.FLLp(2); %���໷��������ֵ
%             obj.carrMode = 2; %ת�����໷
%             log_str = sprintf('Start PLL tracking at %.8fs', obj.dataIndex/obj.sampleFreq);
%             obj.log = [obj.log; string(log_str)];
%         end
%     end
	function freqPull(freqError)
        % FLLp = [K, cnt]
        obj.carrFreq = obj.carrFreq + obj.FLLp(1)*freqError;
        obj.carrNco = obj.carrFreq;
        obj.FLLp(2) = obj.FLLp(2) + 1; %����
        if obj.FLLp(2)==200
            obj.FLLp(2) = 0;
            obj.carrMode = 2; %ת�����໷
            log_str = sprintf('Start PLL tracking at %.8fs', obj.dataIndex/obj.sampleFreq);
            obj.log = [obj.log; string(log_str)];
        end
    end

    %% �������໷
%     function order2PLL(carrError)
%         % PLL2 = [K1, K2, Int]
%         % �����˶�������ز�Ƶ�ʱ仯�����Ǹ���,��Լ��-0.3~-0.6Hz/s
%         % �������ǰ��,����ز�Ƶ��ƫ��,��Լ0.01Hz~0.02Hz
%         % ��֤��ǰ����Ч�����ز���������ֵ,����ǰ����ֵ����ӽ�0
%         carrAcc = obj.carrAccS + obj.carrAccR;
%         obj.PLL2(3) = obj.PLL2(3) + obj.PLL2(2)*carrError + carrAcc*obj.timeIntS;
%         obj.carrNco = obj.PLL2(3) + obj.PLL2(1)*carrError;
%         obj.carrFreq = obj.PLL2(3);
%     end
    function order2PLL(carrError)
        % PLL2 = [K1, K2]
        carrAcc = obj.carrAccS + obj.carrAccR;
        obj.carrFreq = obj.carrFreq + obj.PLL2(2)*carrError + carrAcc*obj.timeIntS;
        obj.carrNco = obj.carrFreq + obj.PLL2(1)*carrError;
    end

    %% ��������໷
    function deepPLL(carrError)
        % PLL2 = [K1, K2]
        % ����Ƶ�ʿ����׻�·����,����Ƶ�ʿ��ⲿ����
        % �μ�����track_sim.m
        dt = obj.timeIntS; %ʱ����
        fi = (obj.carrAccS+obj.carrAccR) * dt; %�ز����ٶ������Ƶ������
        obj.carrFreq = obj.carrFreq + fi;
        obj.carrNco = obj.carrNco + fi;
        df = obj.carrNco - obj.carrFreq;
        dp = -carrError - df*dt;
        obj.remCarrPhase = obj.remCarrPhase - df*dt - obj.PLL2(1)*dt*dp; %alpha=K1*dt
        obj.carrFreq = obj.carrFreq - obj.PLL2(2)*dp; %beta=K2
        if obj.quality<2
            obj.carrFreq = obj.carrNco;
%             if obj.carrFreq>obj.carrNco+1 %�����޷�
%                 obj.carrFreq = obj.carrNco + 1;
%             elseif obj.carrFreq<obj.carrNco-1
%                 obj.carrFreq = obj.carrNco - 1;
%             end
        end
    end

    %% �����ӳ�������
%     function order2DLL(codeError)
%         % DLL2 = [K1, K2, Int]
%         obj.DLL2(3) = obj.DLL2(3) + obj.DLL2(2)*codeError;
%         obj.codeNco = obj.DLL2(3) + obj.DLL2(1)*codeError;
%         obj.codeFreq = obj.DLL2(3);
%     end
    function order2DLL(codeError)
        % DLL2 = [K1, K2]
        obj.codeFreq = obj.codeFreq + obj.DLL2(2)*codeError;
        obj.codeNco = obj.codeFreq + obj.DLL2(1)*codeError;
    end

    %% �뿪��
    function openDLL(deltaFreq)
        % ��Ƶ�����ز�Ƶ��ֱ������
        % ֱ�Ӳ���ز�Ƶ�ʰ������ջ���Ƶ��
        % ���ջ��ӿ�,����ز�Ƶ��ƫС,��Ҫ����,�õ�ʵ�ʵ��ز�Ƶ��
        % ���յ���Ƶ�ʲ��ܽ��ջ���Ƶ���Ӱ��,��Ϊ��Ƶ����ҪӰ���±�Ƶ,�Ե����ź�û��Ӱ��
        carrFreq = obj.carrFreq + deltaFreq*1575.42e6;
        obj.codeNco = 1.023e6 + carrFreq/1540;
        obj.codeFreq = obj.codeNco;
    end

end
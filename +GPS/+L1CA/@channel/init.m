function init(obj, acqResult, n)
% ��ʼ�����ٲ���
% acqResult:������,[����λ,�ز�Ƶ��,��ֵ��ֵ]
% n:�Ѿ������˶��ٸ�������,���ڼ������������

% ��¼������Ϣ
log_str = sprintf('Acquired at %.2fs, peakRatio=%.2f', n/obj.sampleFreq, acqResult(3));
obj.log = [obj.log; string(log_str)];

% ����ͨ��
obj.state = 1;

% ���û���ʱ��,��ʼ��1ms
obj.coherentCnt = 0;
obj.coherentN = 1;
obj.coherentTime = 0.001;

% ȷ�����ݻ������ݶ�
obj.trackDataTail = obj.sampleFreq*0.001 - acqResult(1) + 2;
obj.trackBlockSize = obj.sampleFreq*0.001; %1ms�Ĳ�������
obj.trackDataHead = obj.trackDataTail + obj.trackBlockSize - 1;
obj.dataIndex = obj.trackDataTail + n;

% ��ʼ�������źŷ�����
obj.carrAccS = 0;
obj.carrAccR = 0;
obj.carrAccE = 0;
obj.carrNco = acqResult(2);
obj.codeNco = 1.023e6 + obj.carrNco/1540;
obj.remCarrPhase = 0;
obj.remCodePhase = 0;
obj.carrFreq = obj.carrNco;
obj.codeFreq = obj.codeNco;
obj.carrCirc = 0;

% ��ɻ���I/Qֵ
obj.I_Q = ones(1,6); %����ֵ,�����Ƶ������д���ֵ
obj.I0 = 0;
obj.Q0 = 0;

% ��ʼ��FLLp
K = 40 * 0.001;
cnt = 0; %������
obj.FLLp = [K, cnt];

% ��ʼ��PLL2
Bn = 25;
[K1, K2] = order2LoopCoefD(Bn, 0.707, 0.001);
obj.PLL2 = [K1, K2, Bn];

% ��ʼ��PLL3
% ����С�ڵ���18���ȶ�,<Understanding GPS--Principles and Applications> P180
Bn = 18;
[K1, K2, K3] = order3LoopCoefD(Bn, 0.001);
obj.PLL3 = [K1, K2, K3, Bn];

% ��ʼ��DLL2
Bn = 2;
[K1, K2] = order2LoopCoefD(Bn, 0.707, 0.001);
obj.DLL2 = [K1, K2, Bn];

% ��ʼ������ģʽ
obj.carrMode = 1;
obj.codeMode = 1;

% ��ʼ���������������
obj.discBuff = zeros(3,200);
obj.discBuffPtr = 0;

% ��ʼ����������
% ���������ķ����1/10^(CN0/10)������
% ��ֹʱ�ǱȽ�С��ϵ��,������ϵ�����ԷŴ�
obj.varCoef = zeros(1,6);
obj.varCoef(1) = (0.264*obj.DLL2(3)) * 9e4; %DLLα�෽��,m^2
obj.varCoef(2) = (0.32*obj.PLL2(3))^3 * 0.0363; %PLLα���ʷ���,(m/s)^2
obj.varCoef(3) = 9e4 / 0.008; %�������α�෽��,m^2
obj.varCoef(4) = obj.PLL2(3) * 0.0253; %PLL�ز���λ����,circ^2, 0.0253=1/(2*pi)^2
obj.varCoef(5) = 12.67; %�ز�����������,circ^2, 12.67=1/(2*0.001)/(2*pi)^2
obj.varCoef(6) = 500; %PLL�ز���λ����Ӻź������, 500=1/(2*0.001)
obj.varValue = zeros(1,6);

% ��ʼ��α��ʱ��
obj.tc0 = NaN;

% ��ʼ������ȼ���
obj.CNR = CNR_NWPR(20, 20); %400ms
obj.CN0 = 0;
obj.lossCnt = 0;

% ��ʼ�������ۻ�����
obj.trackCnt = 0;
obj.IpBuff = zeros(1,20);
obj.QpBuff = zeros(1,20);
obj.bitSyncFlag = 0;
obj.bitSyncTable = zeros(1,20);

% ��ʼ�����Ľ�������
obj.msgStage = 'I';
obj.frameBuff = zeros(1,1502); %һ֡����1500����
obj.frameBuffPtr = 0;

end
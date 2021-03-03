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
obj.codeTarget = 2046;
obj.subPhase = 1;
obj.carrDiscFlag = 0;

% ȷ�����ݻ������ݶ�
obj.trackDataTail = obj.sampleFreq*0.01 - acqResult(1) + 2;
obj.trackBlockSize = obj.sampleFreq*0.001; %1ms�Ĳ�������
obj.trackDataHead = obj.trackDataTail + obj.trackBlockSize - 1;
obj.dataIndex = obj.trackDataTail + n;

% ��ʼ�������źŷ�����
obj.carrAccS = 0;
obj.carrAccR = 0;
obj.carrNco = acqResult(2);
obj.codeNco = (1.023e6 + obj.carrNco/1540) * 2; %��Ϊ�����ز�,Ҫ��2
obj.remCarrPhase = 0;
obj.remCodePhase = 0;
obj.carrFreq = obj.carrNco;
obj.codeFreq = obj.codeNco;

% ��ɻ���I/Qֵ
obj.I_Q = ones(1,6); %����ֵ,�����Ƶ������д���ֵ
obj.I0 = 0;
obj.Q0 = 0;

% ��ʼ��FLLp
% ��ʱ������Ƶ��

% ��ʼ��PLL2
[K1, K2] = order2LoopCoefD(25, 0.707, 0.001);
obj.PLL2 = [K1, K2, 25];

% ��ʼ��DLL2
[K1, K2] = order2LoopCoefD(2, 0.707, 0.001);
obj.DLL2 = [K1, K2, 2];

% ��ʼ������ģʽ
obj.carrMode = 2; %ֱ�ӽ����໷
obj.codeMode = 1;

% ��ʼ����������������
obj.codeDiscBuff = zeros(1,200);
obj.codeDiscBuffPtr = 0;

% ��ʼ����������
% ���������ķ����1/10^(CN0/10)������
% ��ֹʱ�ǱȽ�С��ϵ��,������ϵ�����ԷŴ�
obj.varCoef = zeros(1,3);
obj.varCoef(1) = (0.08*obj.DLL2(3)) * 9e4;
obj.varCoef(2) = (0.32*obj.PLL2(3))^3 * 0.0363;
obj.varCoef(3) = 9e4 / 0.072; %���������׼����GPS C/A���1/3
obj.varValue = zeros(1,3);

% ��ʼ��α��ʱ��
obj.tc0 = NaN;

% ��ʼ������ȼ���
obj.CNR = CNR_NWPR(10, 40); %400ms
obj.CN0 = 0;
obj.lossCnt = 0;

% ��ʼ�������ۻ�����
obj.trackCnt = 0;
obj.IpBuff = zeros(1,10);
obj.QpBuff = zeros(1,10);
obj.IdBuff = zeros(1,10);
obj.bitSyncFlag = 0;
obj.bitSyncTable = zeros(1,10);

% ��ʼ�����Ľ�������
obj.msgStage = 'I';
obj.frameBuff = zeros(1,1800); %һ֡����1800����
obj.frameBuffPtr = 0;

end
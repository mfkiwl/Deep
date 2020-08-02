function init(obj, acqResult, n)
% ��ʼ�����ٲ���
% acqResult:������,[����λ,�ز�Ƶ��,��ֵ��ֵ]
% n:�Ѿ������˶��ٸ�������,���ڼ������������

% ��¼������Ϣ
log_str = sprintf('Acquired at %ds, peakRatio=%.2f', n/obj.sampleFreq, acqResult(3));
obj.log = [obj.log; string(log_str)];

% ����ͨ��
obj.state = 1;

% �����뷢�����õ���
% ������,ǰ�����һ����
code = BDS.B1C.codeGene_data(obj.PRN);
code = reshape([code;-code],10230*2,1);
obj.codeData = [code(end);code;code(1)]; %������
code = BDS.B1C.codeGene_pilot(obj.PRN);
code = reshape([code;-code],10230*2,1);
obj.codePilot = [code(end);code;code(1)]; %������
obj.codeSub = BDS.B1C.codeGene_sub(obj.PRN); %������

% ���û���ʱ��,��ʼ��1ms
obj.timeIntMs = 1;
obj.timeIntS = 0.001;
obj.pointInt = 10;
obj.codeTarget = 2046;
obj.subPhase = 1;
obj.carrDiscFlag = 0;

% ȷ�����ݻ������ݶ�
obj.trackDataTail = obj.sampleFreq*0.01 - acqResult(1) + 2;
obj.trackBlockSize = obj.sampleFreq*0.001; %��ʼ��1ms����ʱ��
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

% ��ʼ��I/Q,��Ƶ���õ�
obj.I = 1;
obj.Q = 1;
obj.Id = 0;
obj.Ip = 0;

% ��ʼ��FLLp
% ��ʱ������Ƶ��

% ��ʼ��PLL2
[K1, K2] = order2LoopCoefD(25, 0.707, obj.timeIntS);
obj.PLL2 = [K1, K2];

% ��ʼ��DLL2
[K1, K2] = order2LoopCoefD(2, 0.707, obj.timeIntS);
obj.DLL2 = [K1, K2];

% ��ʼ������ģʽ
obj.carrMode = 1;
obj.codeMode = 1;

% ��ʼ��α��ʱ��
obj.tc0 = NaN;

% ��ʼ�����Ľ�������
obj.msgStage = 'I';
obj.msgCnt = 0;
obj.Ip0 = 0;
obj.bitSyncTable = zeros(1,10); %һ�����س���10ms
obj.bitBuff = zeros(1,10); %�����10��
obj.frameBuff = zeros(1,1800); %һ֡����1800����
obj.frameBuffPtr = 0;

end
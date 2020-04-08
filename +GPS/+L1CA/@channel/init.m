function init(obj, acqResult, n)
% ��ʼ�����ٲ���
% acqResult:������,[����λ,�ز�Ƶ��,��ֵ��ֵ]
% n:�Ѿ������˶��ٸ�������,���ڼ������������

% ��¼������Ϣ
log_str = sprintf('Acquired at %ds, peakRatio=%.2f', n/obj.sampleFreq, acqResult(3));
obj.log = [obj.log; string(log_str)];

% ����ͨ��
obj.state = 1;

% ���ر����뷢�����õ�C/A��
% ������,��������þ���˷������ۼ����
% ǰ�����һ����,����ȡ��ǰ�ͺ���
% ������ʱ��ı�ʱ,codeҪ��ɶ�Ӧ�ĳ���
obj.code = [obj.CAcode(end),obj.CAcode,obj.CAcode(1)]';

% ���û���ʱ��,��ʼ��1ms
obj.timeIntMs = 1;
obj.timeIntS = 0.001;
obj.codeInt = 1023;
obj.pointInt = 20;

% ȷ�����ݻ������ݶ�
obj.trackDataTail = obj.sampleFreq*0.001 - acqResult(1) + 2;
obj.trackBlockSize = obj.sampleFreq*0.001; %0.001��ʾ1ms����ʱ��
obj.trackDataHead = obj.trackDataTail + obj.trackBlockSize - 1;
obj.dataIndex = obj.trackDataTail + n;

% ��ʼ�������źŷ�����
obj.carrAcc = 0;
obj.carrNco = acqResult(2);
obj.codeNco = 1.023e6 + obj.carrNco/1540;
obj.remCarrPhase = 0;
obj.remCodePhase = 0;
obj.carrFreq = obj.carrNco;
obj.codeFreq = obj.codeNco;

% ��ʼ��I/Q,��Ƶ���õ�
obj.I = 1;
obj.Q = 1;

% ��ʼ��FLLp
K = 40 * obj.timeIntS;
Int = obj.carrNco; %������
cnt = 0; %������
obj.FLLp = [K, Int, cnt];

% ��ʼ��PLL2
[K1, K2] = order2LoopCoefD(25, 0.707, obj.timeIntS);
Int = 0; %������
obj.PLL2 = [K1, K2, Int];

% ��ʼ��DLL2
[K1, K2] = order2LoopCoefD(2, 0.707, obj.timeIntS);
Int = obj.codeNco; %������
obj.DLL2 = [K1, K2, Int];

% ��ʼ������ģʽ
obj.carrMode = 1;
obj.codeMode = 1;

% ��ʼ�ź�����
obj.quality = 2;

% ��ʼ��α��ʱ��
obj.tc0 = NaN;

% ��ʼ�����Ľ�������
obj.msgStage = 'I';
obj.msgCnt = 0;
obj.I0 = 0;
obj.bitSyncTable = zeros(1,20); %һ�����س���20ms
obj.bitBuff = zeros(1,20); %�����20��
obj.frameBuff = zeros(1,1502); %һ֡����1500����
obj.frameBuffPtr = 0;

end
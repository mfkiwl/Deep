function run(obj, data)
% ���ջ����к���
% data:��������,����,�ֱ�ΪI/Q����,ԭʼ��������

% �����ݻ������
obj.buffI(:,obj.blockPtr) = data(1,:); %�����ݻ����ָ�������,���ü�ת��,�Զ����������
obj.buffQ(:,obj.blockPtr) = data(2,:);
obj.buffHead = obj.blockPtr * obj.blockSize; %�������ݵ�λ��
obj.blockPtr = obj.blockPtr + 1; %ָ����һ��
if obj.blockPtr>obj.blockNum
    obj.blockPtr = 1;
end
obj.tms = obj.tms + 1; %��ǰ����ʱ���1ms

% ��Ƶ��ϵ��
Cdf = 1 + obj.deltaFreq;
Ddf = obj.deltaFreq / Cdf;

% ���½��ջ�ʱ��
dta = sample2dt(obj.blockSize, obj.sampleFreq*Cdf); %ʱ������
obj.ta = timeCarry(obj.ta + dta);
obj.clockError = obj.clockError + obj.blockTime*Ddf; %�ۼ��Ӳ�������

% GPS�źŲ������
if obj.GPSflag==1
    % ����
    if obj.tms==obj.blockNum || mod(obj.tms,2000)==0 %2s����һ��
        obj.acqProcessGPS;
    end
    % ����
    obj.trackProcessGPS;
end

% �����źŲ������
if obj.BDSflag==1
    % ����
    if obj.tms==obj.blockNum %|| mod(obj.tms,10000)==0 %10s����һ��
        obj.acqProcessBDS;
    end
    % ����
    obj.trackProcessBDS;
end

% ��λ
if (obj.ta-obj.tp)*[1;1e-3;1e-6]>=0 %��λʱ�䵽��
    switch obj.state
        case 0 %��ʼ��
            obj.pos_init;
        case 1 %����
            obj.pos_normal;
%         case 2 %�����
%             obj.pos_tight;
        case 3 %�����
            obj.pos_deep;
    end
end

end
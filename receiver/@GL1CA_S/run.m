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

% ���½��ջ�ʱ��
dta = sample2dt(obj.blockSize, obj.sampleFreq*(1+obj.deltaFreq)); %ʱ������
obj.ta = timeCarry(obj.ta + dta);

% ����
if mod(obj.tms,1000)==0 %1s����һ��
    obj.acqProcess;
end

% ����
obj.trackProcess;

% ��λ
if (obj.ta-obj.tp)*[1;1e-3;1e-6]>=0 %��λʱ�䵽��
    switch obj.state
        case 0 %��ʼ��ģʽ
            obj.pos_init;
        case 1 %����ģʽ
            obj.pos_normal;
        case 2 %�����ģʽ
            obj.pos_tight;
        case 3 %�����ģʽ
            obj.pos_deep;
    end
end

end
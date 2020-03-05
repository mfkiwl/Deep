function get_result(obj)
% ��ȡ���ջ����н��

% ͳ�Ƹ��ٹ��źŵ�ͨ�����������Ǳ��
obj.result.trackedIndex = [];
obj.result.trackedPRN = [];
flag = zeros(1,obj.chN); %�Ƿ���ٵ��źű�־
for k=1:obj.chN
    if obj.channels(k).ns>0
        flag(k) = 1;
    end
end
index = find(flag==1); %ͨ������
obj.result.trackedIndex = index;
n = length(index);
obj.result.trackedPRN = cell(1,n); %���Ǳ�����ַ���Ԫ������
for k=1:n
    obj.result.trackedPRN{k} = sprintf('%d', obj.svList(index(k)));
end

% ͳ�������ǲ�����ͨ�����������Ǳ��
obj.result.satmeasIndex = [];
obj.result.satmeasPRN = [];
if ~isempty(obj.storage.satmeas)
    flag = zeros(1,obj.chN); %�Ƿ�����λ�ñ�־
    for k=1:obj.chN
        if sum(~isnan(obj.storage.satmeas{k}(:,1)))>0 %��ȫ��NaN
            flag(k) = 1;
        end
    end
    index = find(flag==1); %ͨ������
    obj.result.satmeasIndex = index;
    n = length(index);
    obj.result.satmeasPRN = cell(1,n); %���Ǳ�����ַ���Ԫ������
    for k=1:n
        obj.result.satmeasPRN{k} = sprintf('%d', obj.svList(index(k)));
    end
end

end
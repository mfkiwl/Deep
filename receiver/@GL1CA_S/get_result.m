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
    flag = zeros(1,obj.chN); %�Ƿ������ǲ�����־
    for k=1:obj.chN
        if any(~isnan(obj.storage.satmeas{k}(:,1))) %��ȫ��NaN
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

% ͳ�ƿɼ���������
obj.result.svnum = zeros(obj.ns,2,'uint8'); %��һ����ǿ�ź�����,�ڶ�����ǿ+���ź�����
obj.result.svnum(:,1) = sum(obj.storage.svsel==2,2);
obj.result.svnum(:,2) = sum(obj.storage.svsel>=1,2);

end
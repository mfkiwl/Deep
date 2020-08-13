function get_result(obj)
% ��ȡ���ջ����н��

%% ͳ�Ƹ��ٹ��źŵ�ͨ�����������Ǳ��
if obj.GPSflag==1
    obj.result.GPS.trackedIndex = []; %���ٵ�������ͨ������
    obj.result.GPS.trackedPRN = []; %���ٵ������Ǳ���ַ���
    flag = zeros(1,obj.GPS.chN); %�Ƿ���ٵ��źű�־
    for k=1:obj.GPS.chN
        if obj.GPS.channels(k).ns>0
            flag(k) = 1;
        end
    end
    index = find(flag==1); %ͨ������
    obj.result.GPS.trackedIndex = index;
    n = length(index);
    obj.result.GPS.trackedPRN = cell(1,n); %���Ǳ�����ַ���Ԫ������
    for k=1:n
        obj.result.GPS.trackedPRN{k} = sprintf('%d', obj.GPS.svList(index(k)));
    end
end
if obj.BDSflag==1
    obj.result.BDS.trackedIndex = []; %���ٵ�������ͨ������
    obj.result.BDS.trackedPRN = []; %���ٵ������Ǳ���ַ���
    flag = zeros(1,obj.BDS.chN); %�Ƿ���ٵ��źű�־
    for k=1:obj.BDS.chN
        if obj.BDS.channels(k).ns>0
            flag(k) = 1;
        end
    end
    index = find(flag==1); %ͨ������
    obj.result.BDS.trackedIndex = index;
    n = length(index);
    obj.result.BDS.trackedPRN = cell(1,n); %���Ǳ�����ַ���Ԫ������
    for k=1:n
        obj.result.BDS.trackedPRN{k} = sprintf('%d', obj.BDS.svList(index(k)));
    end
end

%% ͳ�ƿɼ�������
obj.result.svnumGPS = zeros(obj.ns,2,'uint8'); %��һ����ǿ�ź�����,�ڶ�����ǿ+���ź�����
obj.result.svnumBDS = zeros(obj.ns,2,'uint8');
obj.result.svnumALL = zeros(obj.ns,2,'uint8');
if obj.GPSflag==1
    obj.result.svnumGPS(:,1) = sum(obj.storage.qualGPS==2,2);
    obj.result.svnumGPS(:,2) = sum(obj.storage.qualGPS>=1,2);
end
if obj.BDSflag==1
    obj.result.svnumBDS(:,1) = sum(obj.storage.qualBDS==2,2);
    obj.result.svnumBDS(:,2) = sum(obj.storage.qualBDS>=1,2);
end
obj.result.svnumALL(:,1) = obj.result.svnumGPS(:,1) + obj.result.svnumBDS(:,1);
obj.result.svnumALL(:,2) = obj.result.svnumGPS(:,2) + obj.result.svnumBDS(:,2);

end
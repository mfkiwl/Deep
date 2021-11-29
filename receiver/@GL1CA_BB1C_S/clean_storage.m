function clean_storage(obj)
% �������ݴ洢

% ����ͨ���ڶ���Ĵ洢�ռ�
if obj.GPSflag==1
    for k=1:obj.GPS.chN
        obj.GPS.channels(k).clean_storage;
    end
end
if obj.BDSflag
    for k=1:obj.BDS.chN
        obj.BDS.channels(k).clean_storage;
    end
end

% ��ȡ���г���,Ԫ������
fields = fieldnames(obj.storage);

% �������Ľ��ջ�����洢�ռ�
n = obj.ns + 1;
for k=1:length(fields)
    if ismatrix(obj.storage.(fields{k})) %��ά�洢�ռ�
        obj.storage.(fields{k})(n:end,:) = [];
    else %��ά�洢�ռ�
        obj.storage.(fields{k})(:,:,n:end) = [];
    end
end

end
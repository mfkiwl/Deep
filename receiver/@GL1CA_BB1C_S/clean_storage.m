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

end
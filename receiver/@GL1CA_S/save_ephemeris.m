function save_ephemeris(obj, filename)
% ��������

load(filename, 'ephemeris') %����Ԥ�������
ephemeris.GPS_iono = obj.iono; %��������У������
for k=1:obj.chN %��ȡ������ͨ��������
    channel = obj.channels(k);
    if ~isnan(channel.ephe(1))
        ephemeris.GPS_ephe(channel.PRN,:) = channel.ephe;
    end
end
save(filename, 'ephemeris') %���浽�ļ���

end
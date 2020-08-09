function save_ephemeris(obj, filename)
% ��������

load(filename, 'ephemeris') %����Ԥ�������

if obj.GPSflag==1
    ephemeris.GPS_iono = obj.GPS.iono; %��������У������
    for k=1:obj.GPS.chN %��ȡ������ͨ��������
        channel = obj.GPS.channels(k);
        if ~isnan(channel.ephe(1))
            ephemeris.GPS_ephe(channel.PRN,:) = channel.ephe;
        end
    end
end

save(filename, 'ephemeris') %���浽�ļ���

end
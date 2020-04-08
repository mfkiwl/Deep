function set_ephemeris(obj, filename)
% Ԥ������

% ���Ԥ�������Ƿ����,��������ھʹ���һ���յ�
if ~exist(filename, 'file')
    ephemeris = []; %������Ϊephemeris,�Ǹ��ṹ��
    save(filename, 'ephemeris') %���浽�ļ���
end

% ����Ԥ�������
load(filename, 'ephemeris')

% ���Ԥ���������Ƿ����GPS����,���������,�����յ�GPS����
if ~isfield(ephemeris, 'GPS_ephe')
    ephemeris.GPS_ephe = NaN(32,25); %ÿ��һ������
    ephemeris.GPS_iono = NaN(1,8);
    save(filename, 'ephemeris') %���浽�ļ���
end

% ��ȡ����
obj.iono = ephemeris.GPS_iono; %��ȡ�����У������
for k=1:obj.chN %Ϊÿ��ͨ��������
    channel = obj.channels(k);
    channel.ephe = ephemeris.GPS_ephe(channel.PRN,:);
end

end
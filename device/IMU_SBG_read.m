function imu = IMU_SBG_read(filepath)
% ����SBG IMU����,�̶�100Hz
% ��һ��ΪGPS��������,s
% ���ٶȵ�λdeg/s,���ٶȵ�λm/s^2

% ���ļ�
fileID = fopen(filepath, 'r');

% ͳ������
fgetl(fileID); %����ǰ����
fgetl(fileID);
n = 0;
while ~feof(fileID)
    fgetl(fileID);
    n = n + 1;
end

% ��ȡ����
data = zeros(n,12);
fseek(fileID, 0, 'bof'); %��ͷ��ʼ
fgetl(fileID); %����ǰ����
fgetl(fileID);
for k=1:n
    tline = fgetl(fileID);
    data(k,:) = sscanf(tline,'%d-%d-%d %d:%d:%f %f %f %f %f %f %f');
end

% �ر��ļ�
fclose(fileID);

% ת����GPSʱ��
t0 = UTC2GPS(data(1,1:6), 0); %��һ������GPSʱ��,�ܺ���
imu = [t0(2)+(0:n-1)'*0.01, data(:,7:12)];

% �����Ƿ���
t1 = UTC2GPS(data(end,1:6), 0); %���һ������GPSʱ��,�ܺ���
if imu(end,1)~=t1(2)
    error('Data lost!')
end

end
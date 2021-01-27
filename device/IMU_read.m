function imu = IMU_read(filepath)
% ��IMU�����ļ�,�����ļ���ǰ׺���ò�ͬ���ļ���������
% filepath:�ļ�����·��
% imu���ݸ�ʽ�̶�,[GPS������.���ٶ�(deg/s),���ٶ�(m/s^2)]

[~, name, ~] = fileparts(filepath); %������ļ���
prefix = strtok(name,'_'); %�ļ���ǰ׺

if contains('ADIS16448',prefix)
    imu = IMU_ADI_read(filepath);
    imu(:,2:4) = movmean(imu(:,2:4),5,1); %Ԥ����
    imu(:,5:7) = movmean(imu(:,5:7),4,1);
    imu(:,5:7) = imu(:,5:7) * 9.80665; %���ٶȵ�λ����m/s^2
elseif contains('SBG',prefix)
    imu = IMU_SBG_read(filepath);
elseif contains('IMU',prefix)
    imu = IMU_SIM_read(filepath);
else
    error('File error!')
end

end
function imu_input(obj, tp, imu)
% IMU��������
% tp:�´εĶ�λʱ��,s
% imu:�´ε�IMU����

obj.tp = sec2smu(tp); %[s,ms,us]
imu(1:3) = imu(1:3)/180*pi; %���ٶȵ�λ����rad/s
obj.imu = imu;

end
function imu_input(obj, tp, imu)
% IMU��������
% tp:�´εĶ�λʱ��,s
% imu:�´ε�IMU����

obj.tp = sec2smu(tp); %[s,ms,us]
obj.imu = imu;

end
function imu = imu_gene(cond)
% ���ɾ�ֹ״̬��IMU����,[deg/s, g]

n = cond.T/cond.dt; %���ݵ���
gyro = randn(n,3)*cond.sigma_gyro + ones(n,1)*cond.bias_gyro; %deg/s
att = cond.att/180*pi; %rad
Cnb = angle2dcm(att(1), att(2), att(3));
gb = (Cnb*[0;0;-1])'; %g,������
acc = ones(n,1)*gb + randn(n,3)*cond.sigma_acc/1000 + ...
      ones(n,1)*cond.bias_acc/1000; %g
imu = [gyro, acc];

end
function dt = sample2dt(n, fs)
% ��������ת��Ϊʱ������(n������ڵ���0)
% n:��������
% fs:����Ƶ��,Hz

dt = [0,0,0]; %[s,ms,us]

t = n / fs;
dt(1) = floor(t); %���벿��
t = mod(t,1) * 1000;
dt(2) = floor(t); %���벿��
dt(3) = mod(t,1) * 1000; %΢�벿��

% dt(1) = floor(n/fs);
% dt(2) = floor(rem(n,fs) * (1e3/fs));
% % (1e3/fs)��ʾһ����������ٺ���,rem(n,fs)��ʾ����1���ж��ٸ�������
% dt(3) = rem(n,(fs/1e3)) * (1e6/fs);
% % (1e6/fs)��ʾһ�����������΢��,rem(n,(fs/1e3))��ʾ����1�����ж��ٸ�������

end
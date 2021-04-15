% У�������ٶȺ���ʵ���ٶ�

% ����Ƿ��Ƿ�������
[~,name,~] = fileparts(data_file); %�ļ������
prefix = strtok(name, '_');
if ~strcmp(prefix,'SIM') %���Ƿ������ݷ���
    return
end

% ���ع켣����
trajnum = name(end-1:end); %�켣���,��λ
load(['~temp\traj\traj0',trajnum])
dt_traj = trajGene_conf.dt; %�켣�������
dt_pos = nCoV.dtpos/1000; %���ջ��������
m = dt_pos / dt_traj; %������

% ���ɹ켣��ʱ������
startTime_gps = UTC2GPS(tf, 8); %��ʼ��GPSʱ��
tow = startTime_gps(2); %������
n = size(traj,1);
time = tow + (0:n-1)'*dt_traj;

% ����
n1 = find(time==nCoV.storage.ta(1),1);
n2 = find(time==nCoV.storage.ta(end),1);

vel_real = traj(n1:m:n2,10:12); %��ʵ�ٶ�
x1 = nCoV.storage.satnav(:,4)-vel_real(:,1); %�����ǵ��������
x2 = nCoV.storage.satnav(:,5)-vel_real(:,2);
x3 = nCoV.storage.satnav(:,6)-vel_real(:,3);
y1 = nCoV.storage.vel(:,1)-vel_real(:,1); %�˲�������
y2 = nCoV.storage.vel(:,2)-vel_real(:,2);
y3 = nCoV.storage.vel(:,3)-vel_real(:,3);

t = nCoV.storage.ta - nCoV.storage.ta(end) + nCoV.Tms/1000;

figure('Name','dVx')
plot(t,[x1,y1])
grid on
figure('Name','dVy')
plot(t,[x2,y2])
grid on
figure('Name','dVz')
plot(t,[x3,y3])
grid on
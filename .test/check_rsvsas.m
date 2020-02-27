% ��֤���ַ����������Ǽ��ٶ�
% �ڶ��ַ�������,��Ϊ�ٽ���һ�ο����շ���
% ����ǰ������һ��Ԥ������

% ��Ԥ��������ȡһ������,16����
ephe = ephemeris.GPS_ephe(24,10:end);

n = 10*3600; %�������
t0 = 475200; %ʱ�����,�������е�toe

%% ����1
sv1 = zeros(n,9); %[x,y,x,vx,vy,vz,ax,ay,az]
T = 0.1; %���ʱ����,s
t = t0;
for k=1:n
    [rsvs1, ~] = LNAV.rsvs_ephe(ephe, t);
    [rsvs2, ~] = LNAV.rsvs_ephe(ephe, t+T);
    sv1(k,1:6) = rsvs1;
    sv1(k,7:9) = (rsvs2(4:6)-rsvs1(4:6)) / T; %�ٶ����������ٶ�
    t = t+1; %ǰ��1s
end

%% ����2
sv2 = zeros(n,9); %[x,y,x,vx,vy,vz,ax,ay,az]
t = t0;
for k=1:n
    [sv2(k,:), ~] = LNAV.rsvsas_ephe(ephe, t);
    t = t+1; %ǰ��1s
end

%% �Ƚϲ���
dsv = sv1-sv2;
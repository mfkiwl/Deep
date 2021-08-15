% ��ȡSpirent�����������.csv�ļ�

[file, path] = uigetfile('~temp\spirent\*.csv');
if ~ischar(file)
    error('File error!')
end
fileID = fopen([path,file]);
tline = fgetl(fileID);
fclose(fileID);

%% ��ȡ��ʼʱ��
A = sscanf(tline,'%d,%d,%d,%d,GDOP,%d');
t0 = mod(A(5),604800); %���ݿ�ʼʱ��,��GPS��ʱ�̿�ʼ������

%% �����
opts = delimitedTextImportOptions("NumVariables", 38);
opts.DataLines = [3, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["Time_ms", "Pos_X", "Pos_Y", "Pos_Z", "Vel_X", "Vel_Y", "Vel_Z", "Acc_X", "Acc_Y", "Acc_Z", "Jerk_X", "Jerk_Y", "Jerk_Z", "Lat", "Long", "Height", "Heading", "Elevation", "Bank", "Angvel_X", "Angvel_Y", "Angvel_Z", "Angacc_X", "Angacc_Y", "Angacc_Z", "Ant1_Pos_X", "Ant1_Pos_Y", "Ant1_Pos_Z", "Ant1_Vel_X", "Ant1_Vel_Y", "Ant1_Vel_Z", "Ant1_Acc_X", "Ant1_Acc_Y", "Ant1_Acc_Z", "Ant1_Lat", "Ant1_Long", "Ant1_Height", "Ant1_DOP"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
motionV1 = readtable([path,file], opts);
motionV1 = table2array(motionV1);

%% ��������
% motionSim = [t,lat,lon,h,vn,ve,vd,an,ae,ad]
n = size(motionV1,1);
motionSim = zeros(n,10);
motionSim(:,1) = t0 + motionV1(:,1)/1000; %ʱ��
motionSim(:,2:4) = motionV1(:,14:16); %γ����λ��
motionSim(:,2:3) = motionSim(:,2:3)/pi*180; %ת����deg
for k=1:n
    Cen = dcmecef2ned(motionSim(k,2),motionSim(k,3));
    motionSim(k,5:7) = Cen*motionV1(k,5:7)'; %����ϵ�µ��ٶ�
    geogInfo = geogInfo_cal(motionSim(k,2:4), motionSim(k,5:7)); %���������Ϣ
    motionSim(k,8:10) = Cen*(motionV1(k,8:10)-cross(geogInfo.wene,motionV1(k,5:7)))'; %�������ϵ�µļ��ٶ�,�μ��������̱ʼ�
end

%% ��ͼ
t = motionSim(:,1) - t0;
figure('Name','λ��')
subplot(3,1,1)
plot(t,motionSim(:,2))
grid on
subplot(3,1,2)
plot(t,motionSim(:,3))
grid on
subplot(3,1,3)
plot(t,motionSim(:,4))
grid on

figure('Name','�ٶ�')
subplot(3,1,1)
plot(t,motionSim(:,5))
grid on
subplot(3,1,2)
plot(t,motionSim(:,6))
grid on
subplot(3,1,3)
plot(t,motionSim(:,7))
grid on
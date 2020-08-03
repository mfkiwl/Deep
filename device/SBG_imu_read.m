function varargout = SBG_imu_read(plotflag)
% ����SBG IMU����,�̶�100Hz
% ��һ��ΪGPS��������,s
% ���ٶȵ�λdeg/s,���ٶȵ�λm/s^2

% ѡ���ļ�
[file, path] = uigetfile('*.txt', 'ѡ��SBG�����ļ�'); %�ļ�ѡ��Ի���
if ~ischar(file)
    error('File error!')
end
filename = [path, file]; %�����ļ�����·��,path����\

% ���ļ�
fileID = fopen(filename);

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

% ת����GPSʱ��
t0 = UTC2GPS(data(1,1:6), 0); %��һ������GPSʱ�䣬�ܺ���
imu_data = [t0(2)+(0:n-1)'*0.01, data(:,7:12)];

% �����Ƿ���
t1 = UTC2GPS(data(end,1:6), 0); %���һ������GPSʱ�䣬�ܺ���
if imu_data(end,1)~=t1(2)
    error('Data lost!')
end

% �ر��ļ�
fclose(fileID);

% ��ͼ
if plotflag
    figure
    t = imu_data(:,1) - imu_data(1,1);
    subplot(3,2,1)
    plot(t,imu_data(:,2))
    grid on
    set(gca, 'xlim', [t(1),t(end)])
    subplot(3,2,3)
    plot(t,imu_data(:,3))
    grid on
    set(gca, 'xlim', [t(1),t(end)])
    subplot(3,2,5)
    plot(t,imu_data(:,4))
    grid on
    set(gca, 'xlim', [t(1),t(end)])
    subplot(3,2,2)
    plot(t,imu_data(:,5))
    grid on
    set(gca, 'xlim', [t(1),t(end)])
    subplot(3,2,4)
    plot(t,imu_data(:,6))
    grid on
    set(gca, 'xlim', [t(1),t(end)])
    subplot(3,2,6)
    plot(t,imu_data(:,7))
    grid on
    set(gca, 'xlim', [t(1),t(end)])
end

% ���
if nargout==1
    varargout{1} = imu_data;
end

end
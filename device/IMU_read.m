function varargout = IMU_read(plotflag)
% ����IMU����,��ʱ���ת��ΪGPSʱ��
% ʱ�䵥λs,���ٶȵ�λdeg/s,���ٶȵ�λg
% plotflag:�Ƿ�ͼ��־,0/1
% ������ʽ,ʹ�öԻ���ѡ���ļ�
% ʹ�ÿɱ�������,ʹ�ó������ֱ������,�����

%% ���ļ�
valid_prefix = 'ADIS16448-IMU5210-'; %�ļ�����Чǰ׺
[file, path] = uigetfile('*.dat', 'ѡ��IMU�����ļ�'); %�ļ�ѡ��Ի���
if ~ischar(file) || ~contains(valid_prefix, strtok(file,'_'))
    error('File error!')
end
fileID = fopen([path,file], 'r');
stream = fread(fileID, 'uint8=>uint8');
fclose(fileID);

%% ����ԭʼ����
% [cnt, year,mon,day, hour,min,sec, TIM3, wx,wy,wz, fx,fy,fz, temp, PPS_error]
% ÿ֡27�ֽ�,16����
% cntÿ֡���ݼ�1,TIM3ÿ0.1ms��1,PPS_errorÿ��⵽һ��PPS�����1
n = length(stream); %���ֽ���
data = zeros(ceil(n/27),16); %������ԭʼ����
k = 1; %�ֽ�����
m = 1; %���ݴ洢��
while 1
    if k+26>n %ʣ�µ������Ѿ�����������֡,�˳�
        break
    end
    if stream(k)==85 && stream(k+26)==170 %֡ͷ0x55,֡β0xAA
        buff = stream(k+(0:26)); %��ȡһ֡
        data(m,1) = buff(3); %cnt
        data(m,2) = buff(4); %year
        data(m,3) = buff(5); %mon
        data(m,4) = buff(6); %day
        data(m,5) = buff(7); %hour
        data(m,6) = buff(8); %min
        data(m,7) = buff(9); %sec
        data(m,8) = typecast(buff(10:11),'uint16'); %TIM3
        data(m,16) = buff(26); %PPS_error
        switch buff(2) %�����豸�Ž�������ת��
            case 0
                data(m,10) =  double(typecast(buff(12:13),'int16')) /32768*300;
                data(m,9)  =  double(typecast(buff(14:15),'int16')) /32768*300;
                data(m,11) = -double(typecast(buff(16:17),'int16')) /32768*300;
                data(m,13) =  double(typecast(buff(18:19),'int16')) /32768*10;
                data(m,12) =  double(typecast(buff(20:21),'int16')) /32768*10;
                data(m,14) = -double(typecast(buff(22:23),'int16')) /32768*10;
                data(m,15) =  double(typecast(buff(24:25),'int16')) /10; %�¶�
            case 1
                data(m,10) = -double(typecast(buff(12:13),'int16')) /50;
                data(m,9)  = -double(typecast(buff(14:15),'int16')) /50;
                data(m,11) = -double(typecast(buff(16:17),'int16')) /50;
                data(m,13) = -double(typecast(buff(18:19),'int16')) /1200;
                data(m,12) = -double(typecast(buff(20:21),'int16')) /1200;
                data(m,14) = -double(typecast(buff(22:23),'int16')) /1200;
                data(m,15) =  double(typecast(buff(24:25),'int16')) *0.07386 + 31; %�¶�
        end
        m = m+1; %ָ����һ�洢��
        k = k+27; %ָ����һ֡
    else
        k = k+1; %ָ����һ�ֽ�
    end
end
if m==1
    error('No data!')
end
data(m:end,:) = []; %ɾ���հ�����
data(:,2) = data(:,2) + 2000; %��ݼ�2000

%% У��cnt,PPS_error
cnt_diff = mod(diff(data(:,1)),256);
if sum(cnt_diff~=1)~=0 %cnt���������1
    error('cnt error!')
end
if sum(data(:,16)~=data(1,16))~=0 %PPS_error���붼��ͬ
    error('PPS_error error!')
end

%% ͳ�Ʋ���ʱ��
if plotflag
    sample_time = mod(diff(data(:,8)),10000); %����ʱ��,ֻ��Ϊ99,100,101,��λ,0.1ms
    figure
    plot(sample_time)
    title('����ʱ��')
    sample_time_mean = cumsum(sample_time) ./ (1:length(sample_time))'; %ƽ������ʱ��,������Ϊ10ms,ʵ�ʿ����Ը߻��Ե�
    figure
    plot(sample_time_mean)
    grid on
    title('ƽ������ʱ��')
end

%% ��ȡIMU����,��ʱ���ת��ΪGPS��������
n = length(data);
imu_data = zeros(n,7); %IMU����,[t, wx,wy,wz, fx,fy,fz], deg/s, g
imu_data(:,2:7) = data(:,9:14);
t0 = UTC2GPS(data(1,2:7), 0); %��һ�����ʱ��,[week,second],ʱ����0
ts = t0(2);
imu_data(1,1) = ts + data(1,8)/10000;
for k=2:n
    if data(k,7)~=data(k-1,7) %��ǰ��һ�����������һ��,������1
        ts = ts+1;
    end
    imu_data(k,1) = ts + data(k,8)/10000;
end

%% ���ʱ���Ƿ���ȷ
time_diff = diff(imu_data(:,1));
if sum(time_diff>0.0102)~=0 || sum(time_diff<0.0098)~=0 %����ʱ��Ӧ����10ms
    error('time error!')
end

%% ��IMU����
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

%% ���
if nargout==1
    varargout{1} = imu_data;
end

end
% �ļ�Ԥ����,����time,rho,rhodot����

clear
clc

[file, path] = uigetfile('C:\Users\longt\Desktop\sscom\*.DAT');
if ~ischar(file)
    error('File error!')
end
fileID = fopen([path,file]);

% ͳ����������
N = 0;
while ~feof(fileID)
    tline = fgetl(fileID);
    if strcmp(tline(1:4),'time')
        N = N+1;
    end
end
fseek(fileID, 0, 'bof'); %�Ƶ��ļ���ͷ

% ������α��α����
time = zeros(N,3); %ʱ������
rho = NaN(N,32); %α��
rhodot = NaN(N,32); %α����

% ������Ϣ
codeFreq = NaN(N,32);
carrFreq = NaN(N,32);
carrNco  = NaN(N,32);
carrAccS = NaN(N,32);
carrAccR = NaN(N,32);
carrAccE = NaN(N,32);
CN0 = NaN(N,32);

% ���߽�����
pos = NaN(N,3);
vel = NaN(N,3);
clk = NaN(N,2);

% �����˲����
posF = NaN(N,3);
velF = NaN(N,3);
accF = NaN(N,3);
clkF = NaN(N,2);
stdF = NaN(N,3);

% ��¼��������
k = 0;
while ~feof(fileID)
    tline = fgetl(fileID);
    %----���ջ�ʱ��
    if strcmp(tline(1:4),'time')
        k = k+1;
        data = sscanf(tline, 'time: %d %d %f')';
        time(k,:) = data;
    end
    %----α��α����
    if strcmp(tline(1:2),'m:')
        %----��ʽ1
        data = sscanf(tline, 'm:%d %d %f %f %d %f %d %f %f %f %d')';
        PRN = data(2); %���Ǻ�
        rho(k,PRN) = data(3);
        rhodot(k,PRN) = data(4);
        CN0(k,PRN) = data(6);
        carrFreq(k,PRN) = data(4);
        carrNco(k,PRN) = data(8);
        carrAccR(k,PRN) = data(9);
        carrAccE(k,PRN) = data(10);
        %----��ʽ2
        % �������ݸ�ʽ
    end
    %----�������ǵ���������
    if strcmp(tline(1:3),'Ps:')
        data = sscanf(tline, 'Ps:%f %f %f')';
        pos(k,:) = data;
    end
    if strcmp(tline(1:3),'Vs:')
        data = sscanf(tline, 'Vs:%f %f %f')';
        vel(k,:) = data;
    end
    if strcmp(tline(1:3),'Cs:')
        data = sscanf(tline, 'Cs:%f %f')';
        clk(k,:) = data;
    end
    %----�����˲����
    if strcmp(tline(1:3),'Pf:')
        data = sscanf(tline, 'Pf:%f %f %f')';
        posF(k,:) = data;
    end
    if strcmp(tline(1:3),'Vf:')
        data = sscanf(tline, 'Vf:%f %f %f')';
        velF(k,:) = data;
    end
    if strcmp(tline(1:3),'Af:')
        data = sscanf(tline, 'Af:%f %f %f')';
        accF(k,:) = data;
    end
    if strcmp(tline(1:3),'Cf:')
        data = sscanf(tline, 'Cf:%f %f')';
        clkF(k,:) = data;
    end
end

fclose(fileID);
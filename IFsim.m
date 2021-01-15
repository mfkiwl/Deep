% GPS�źŷ���

clear
clc
fclose('all');

%% ����
startTime = [2020,7,27,11,16,14]; %���濪ʼʱ��
zone = 8; %ʱ��
runTime = 60; %��������ʱ��,s
step = 5; %���沽��,ms
eleMask = 10; %�����߶Ƚ�,deg
clockError = 4e-3; %���ջ���Ƶ��,������ʾ�ӿ�,ppm
sampleFreq = 4e6; %����Ƶ��,Hz
gain = 100; %����

%% �켣ģʽ
trajMode = 0; %�켣ģʽ,0-��ֹ,1-��̬
if trajMode==0
    p0 = [45.7364, 126.70775, 165];
    rp = lla2ecef(p0);
    traj = ones(runTime*1000/step+1,1) * [rp,0,0,0]; %����ÿ��ʱ�̵�λ����̬,��̬Ĭ�϶���0
else
    load('~temp\traj.mat') %���ع켣
    if dt*1000~=step %�켣�Ĳ�����������沽�����
        error('Step mismatch!')
    end
end

%% ����ģʽ
satMode = 0; %����ģʽ,0-���ݽ����߶Ƚ��Զ�����,1-ָ�������б�
if satMode==1
    svList = [3,17,19,28];
    svN = length(svList); %�ɼ�������Ŀ
end

%% ����ʱ��
startTime_utc = startTime - [0,0,0,zone,0,0]; %���濪ʼ��UTCʱ��
startTime_gps = UTC2GPS(startTime, zone); %���濪ʼ��GPSʱ��
startTime_tow = startTime_gps(2); %��������

%% �����źŷ������
sats = GPS.L1CA.signalSim.empty; %������Ŀվ���
for k=1:32
    sats(k) = GPS.L1CA.signalSim(k, sampleFreq);
end
sats = sats'; %ת����������

%% ���������ģʽ
%----����������������óɳ�ֵ
% for k=1:32
%     sats(k).cnrMode = 1;
%     sats(k).cnrValue = 48;
% end
%----Ϊָ��������������ȱ�
% cnrTable1 = [0, 10, 15, 25, 30;
%             55, 55, 35, 35, 25;
%              0, -4,  0, -2,  0];
% cnrTable1(1,2:end) = cnrTable1(1,2:end) + startTime_tow;
% sats(17).cnrMode = 2;
% sats(17).cnrTable = cnrTable1;

%% ��ȡ����
filename = GPS.ephemeris.download('~temp\ephemeris', datestr(startTime_utc,'yyyy-mm-dd'));
ephe = RINEX.read_N2(filename);
for k=1:32
    if ~isempty(ephe.sv{k}) && ephe.sv{k}(1).health==0 %��֤�������������ǽ���
        index = find([ephe.sv{k}.TOW]<=startTime_tow, 1, 'last'); %����tow�ҵ�����������ڵ���
        ephe_cell = struct2cell(ephe.sv{k}(index)); %�����ṹ��ת����Ԫ������
        sats(k).ephe = [ephe_cell{:}]; %Ϊÿ�����Ǹ�����
        sats(k).update_message(startTime_tow-0.07); %���µ�������
    end
end

%% ���Ʋ���
loopN = runTime*1000 / step; %ѭ������
sampleN = sampleFreq/1000 * step; %һ��ѭ���Ĳ�������
clockErrorFactor = 1 / (1 + clockError*1e-6); %�������ջ�������n��ʵ�����˶೤ʱ��
ele = zeros(1,32); %���Ǹ߶Ƚ�
te0 = zeros(32,3); %�ϴη���ʱ��(������),[s,ms,us]
tr0 = [startTime_tow,0,0]; %�ϴν��ջ���ʱ��,[s,ms,us]

%% �����ļ�
startTime_str = sprintf('%4d%02d%02d_%02d%02d%02d', startTime);
fileID = fopen(['SIM_',startTime_str,'_ch1.dat'], 'w');

%% ����������
waitbar_str = ['s/',num2str(runTime),'s']; %�������в�����ַ���
f = waitbar(0, ['0',waitbar_str]);

%% ��������
tic
for k=1:loopN
    % ����������Ǹ߶Ƚ�,���¿ɼ������б�
    tn0 = (k-1) * step / 1000; %�ϴν��ջ�������ʱ��
    if mod(tn0,1)==0
        waitbar((tn0+1)/runTime, f, [sprintf('%d',tn0+1),waitbar_str]); %���½�����
        %----�����������Ǹ߶Ƚ�
        rp = traj(k,1:3); %�ϴ�λ��
        tr0_real = timeCarry(sec2smu(tn0 * clockErrorFactor)); 
        tr0_real(1) = tr0_real(1) + startTime_tow; %�ϴ���ʵʱ��
        for PRN=1:32
            sats(PRN).update_aziele(tr0(1), ecef2lla(rp));
            ele(PRN) = sats(PRN).ele;
        end
        %----ѡ������
        if satMode==0 %���ݽ����߶Ƚ�ѡ����
            svList = find(ele>eleMask); %���¿ɼ������б�
            svN = length(svList); %�ɼ�������Ŀ
            for PRN=svList
                te0(PRN,:) = LNAV.transmit_time(sats(PRN).ephe(5:25), tr0_real, rp); %��¼����ʱ��
            end
        else %ָ������
            if tn0==0 %ֻ�ڿ�ʼʱ��һ��
                for PRN=svList
                    te0(PRN,:) = LNAV.transmit_time(sats(PRN).ephe(5:25), tr0_real, rp); %��¼����ʱ��
                end
            end
        end
    end
    
    % ���ɿɼ����ǵ��ź�
    tn = k * step / 1000; %��ǰ���ջ�������ʱ��
    rp = traj(k+1,1:3); %��ǰλ��
    att = traj(k+1,4:6); %��ǰ��̬,deg
    tr = timeCarry(sec2smu(tn));
    tr(1) = tr(1) + startTime_tow; %��ǰ���ջ���ʱ��
    tr_real = timeCarry(sec2smu(tn * clockErrorFactor));
    tr_real(1) = tr_real(1) + startTime_tow; %��ǰ��ʵʱ��
    comSigI = randn(1,sampleN); %�ϳ��ź�
    comSigQ = randn(1,sampleN);
    for m=1:svN
        PRN = svList(m); %���Ǻ�
        te = LNAV.transmit_time(sats(PRN).ephe(5:25), tr_real, rp); %���㷢��ʱ��
        [sigI, sigQ] = sats(PRN).gene_signal(te0(PRN,:), te, tr0, tr, sampleN, att); %�����ź�
        comSigI = comSigI + sigI;
        comSigQ = comSigQ + sigQ;
        te0(PRN,:) = te; %��¼����ʱ��
    end
    tr0 = tr; %��¼���ջ���ʱ��
    
    % д���ļ�
    fwrite(fileID, int16([comSigI;comSigQ]*gain), 'int16');
end
toc

%% �ر��ļ�,�رս�����
fclose(fileID);
close(f);
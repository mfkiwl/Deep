% GPS�źŷ���

clearvars -except IFsim_conf IFsim_GUIflag
clc
fclose('all');

%% ��Ƶ�źŷ�������Ԥ��ֵ
% ʹ��GUIʱ�ⲿ������IFsim_conf,����IFsim_GUIflag��1
if ~exist('IFsim_GUIflag','var') || IFsim_GUIflag~=1
    IFsim_conf.startTime = [2020,7,27,11,16,14]; %���濪ʼʱ��
    IFsim_conf.zone = 8; %ʱ��
    IFsim_conf.runTime = 120; %��������ʱ��,s
    IFsim_conf.step = 0.005; %���沽��,s
    IFsim_conf.eleMask = 10; %�����߶Ƚ�,deg
    IFsim_conf.clockError = 4e-9; %���ջ���Ƶ��,������ʾ�ӿ�
    IFsim_conf.sampleFreq = 4e6; %����Ƶ��,Hz
    IFsim_conf.gain = 100; %����
    IFsim_conf.trajMode = 1; %�켣ģʽ,0-��ֹ,1-��̬
    IFsim_conf.p0 = [45.7364, 126.70775, 165]; %��ֹλ��
    IFsim_conf.trajName = 'traj004'; %�켣��
    IFsim_conf.satMode = 0; %����ģʽ,0-���ݽ����߶Ƚ��Զ�����,1-ָ�������б�
    IFsim_conf.svList = [3,17,19,28]; %�����б�
end
if exist('IFsim_GUIflag','var')
    IFsim_GUIflag = 0;
end

%% ����
startTime = IFsim_conf.startTime; %���濪ʼʱ��
zone = IFsim_conf.zone; %ʱ��
runTime = IFsim_conf.runTime; %��������ʱ��,s
step = IFsim_conf.step; %���沽��,s
eleMask = IFsim_conf.eleMask; %�����߶Ƚ�,deg
clockError = IFsim_conf.clockError; %���ջ���Ƶ��,������ʾ�ӿ�
sampleFreq = IFsim_conf.sampleFreq; %����Ƶ��,Hz
gain = IFsim_conf.gain; %����
trajMode = IFsim_conf.trajMode; %�켣ģʽ,0-��ֹ,1-��̬
p0 = IFsim_conf.p0; %��ֹλ��
trajName = IFsim_conf.trajName; %�켣��
satMode = IFsim_conf.satMode; %����ģʽ,0-���ݽ����߶Ƚ��Զ�����,1-ָ�������б�
svList = IFsim_conf.svList; %�����б�

%% ���ع켣
if trajMode==0
    rp = lla2ecef(p0);
    traj = ones(runTime/step+1,1) * [rp,0,0,0]; %����ÿ��ʱ�̵�λ����̬,��̬Ĭ�϶���0
else
    load(['~temp\traj\',trajName,'.mat']) %���ع켣
    if trajGene_conf.dt~=step %�켣�Ĳ�����������沽�����
        error('Step mismatch!')
    end
    if trajGene_conf.Ts<runTime %�켣ʱ�������ڷ���ʱ��
        error('runTime error!')
    end
end

%% �켣��ֵ����
t = (0:step:runTime)'; %ʱ������
n = length(t);
P1 = griddedInterpolant(t,traj(1:n,1),'pchip');
P2 = griddedInterpolant(t,traj(1:n,2),'pchip');
P3 = griddedInterpolant(t,traj(1:n,3),'pchip');

%% ����ʱ��
startTime_utc = startTime - [0,0,0,zone,0,0]; %���濪ʼ��UTCʱ��
startTime_gps = UTC2GPS(startTime, zone); %���濪ʼ��GPSʱ��
startTime_tow = startTime_gps(2); %��������

%% �����źŷ������
sats = GPS.L1CA.signalSim.empty; %������Ŀվ���
for k=1:32
    sats(k) = GPS.L1CA.signalSim(k, sampleFreq, sampleFreq*step*2);
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
step2 = step*2; %���κ�����ֵ,һ��������
loopN = runTime / step2; %ѭ������
sampleN = sampleFreq * step2; %һ��ѭ���Ĳ�������
clockErrorFactor = 1 / (1 + clockError); %�������ջ�������n��ʵ�����˶೤ʱ��
clock0 = [startTime_tow,0,0]; %��ʼ���ջ���ʱ��(���Ӳ�),[s,ms,us]
ele = zeros(1,32); %���Ǹ߶Ƚ�
te0 = zeros(32,3); %�ϴη���ʱ��(������),[s,ms,us]
tr0 = clock0; %�ϴν��ջ���ʱ��,[s,ms,us]

%% �����ļ�
startTime_str = sprintf('%4d%02d%02d_%02d%02d%02d', startTime);
if trajMode==0
    fileID = fopen(['~temp\data\SIM_',startTime_str,'_000.dat'], 'w');
else
    fileID = fopen(['~temp\data\SIM_',startTime_str,'_',trajName(end-2:end),'.dat'], 'w');
end

%% ����������
waitbar_str = ['s/',num2str(runTime),'s']; %�������в�����ַ���
f = waitbar(0, ['0',waitbar_str]);

%% ��������
tic
for k=1:loopN
    % ����������Ǹ߶Ƚ�,���¿ɼ������б�
    tn0 = (k-1)*step2; %�ϴν��ջ�������ʱ��
    dt0 = tn0 * clockErrorFactor; %�ϴ�ʵ������ʱ��
    if mod(tn0,1)==0
        waitbar((tn0+1)/runTime, f, [sprintf('%d',tn0+1),waitbar_str]); %���½�����
        %----�����������Ǹ߶Ƚ�
        rp0 = [P1(dt0), P2(dt0), P3(dt0)]; %�ϴ�λ��
        tr0_real = timeCarry(sec2smu(dt0)) + clock0; %�ϴ���ʵʱ��
        for PRN=1:32
            sats(PRN).update_aziele(tr0_real(1), ecef2lla(rp0));
            ele(PRN) = sats(PRN).ele;
        end
        %----ѡ������
        if satMode==0 %���ݽ����߶Ƚ�ѡ����
            svList = find(ele>eleMask); %���¿ɼ������б�
            svN = length(svList); %�ɼ�������Ŀ
            for PRN=svList
                te0(PRN,:) = LNAV.transmit_time(sats(PRN).ephe(5:25), tr0_real, rp0); %��¼����ʱ��
            end
        else %ָ������
            if tn0==0 %ֻ�ڿ�ʼʱ��һ��
                svN = length(svList); %�ɼ�������Ŀ
                for PRN=svList
                    te0(PRN,:) = LNAV.transmit_time(sats(PRN).ephe(5:25), tr0_real, rp0); %��¼����ʱ��
                end
            end
        end
    end
    
    % ���ɿɼ����ǵ��ź�
    tn1 = k*step2 - step; %�м���ջ�������ʱ��
    dt1 = tn1 * clockErrorFactor; %�м�ʵ������ʱ��
    tr1 = timeCarry(sec2smu(tn1)) + clock0; %�м���ջ���ʱ��
    tr1_real = timeCarry(sec2smu(dt1)) + clock0; %�м���ʵʱ��
    tn2 = k*step2; %��ǰ���ջ�������ʱ��
    dt2 = tn2 * clockErrorFactor; %��ǰʵ������ʱ��
    tr2 = timeCarry(sec2smu(tn2)) + clock0; %��ǰ���ջ���ʱ��
    tr2_real = timeCarry(sec2smu(dt2)) + clock0; %��ǰ��ʵʱ��
    rp1 = [P1(dt1), P2(dt1), P3(dt1)]; %�м�λ��
    rp2 = [P1(dt2), P2(dt2), P3(dt2)]; %��ǰλ��
    att = traj(2*k-1,4:6); %��̬,deg
    comSigI = randn(1,sampleN); %�ϳ��ź�
    comSigQ = randn(1,sampleN);
    for m=1:svN
        PRN = svList(m); %���Ǻ�
        te1 = LNAV.transmit_time(sats(PRN).ephe(5:25), tr1_real, rp1); %���㷢��ʱ��
        te2 = LNAV.transmit_time(sats(PRN).ephe(5:25), tr2_real, rp2);
        [sigI, sigQ] = sats(PRN).gene_signal([te0(PRN,:);te1;te2], [tr0;tr1;tr2], att); %�����ź�
        comSigI = comSigI + sigI;
        comSigQ = comSigQ + sigQ;
        te0(PRN,:) = te2; %��¼����ʱ��
    end
    tr0 = tr2; %��¼���ջ���ʱ��
    
    % д���ļ�
    fwrite(fileID, int16([comSigI;comSigQ]*gain), 'int16');
end
toc

%% �ر��ļ�,�رս�����
fclose(fileID);
close(f);

%% �������
clearvars
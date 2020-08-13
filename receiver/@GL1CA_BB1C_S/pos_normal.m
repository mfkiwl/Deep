function pos_normal(obj)
% ������λ

%% ����Ȩ
% % ��ȡ���ǲ�����Ϣ & �������ǵ�������
% if obj.GPSflag==1
%     satmeasGPS = obj.get_satmeasGPS;
%     sv = satmeasGPS(~isnan(satmeasGPS(:,1)),:); %ѡ��
%     satnavGPS = satnavSolve(sv, obj.rp);
% end
% if obj.BDSflag==1
%     satmeasBDS = obj.get_satmeasBDS;
%     sv = satmeasBDS(~isnan(satmeasBDS(:,1)),:); %ѡ��
%     satnavBDS = satnavSolve(sv, obj.rp);
% end
% 
% % ���ǵ�������
% if obj.GPSflag==1 && obj.BDSflag==0
%     satnav = satnavGPS;
% elseif obj.GPSflag==0 && obj.BDSflag==1
%     satnav = satnavBDS;
% elseif obj.GPSflag==1 && obj.BDSflag==1
%     satmeas = [satmeasGPS; satmeasBDS];
%     sv = satmeas(~isnan(satmeas(:,1)),:); %ѡ��
%     satnav = satnavSolve(sv, obj.rp);
% end
% dtr = satnav(13); %���ջ��Ӳ�,s
% dtv = satnav(14); %���ջ���Ƶ��,s/s

%% ��Ȩ
% ����
Lca = 299792458/1575.42e6; %�ز���,m
Lco = 299792458/1.023e6; %�볤,m

% ��ȡ���ǲ�����Ϣ & ��ȡͨ����Ϣ & �������ǵ�������
if obj.GPSflag==1
    satmeasGPS = obj.get_satmeasGPS; %���ǲ�����Ϣ
    [~, ele] = aziele_xyz(satmeasGPS(:,1:3), obj.pos); %���Ǹ߶Ƚ�
    %---------------------------------------------------------------------%
    chN = obj.GPS.chN;
    quality = zeros(chN,1); %�ź�����
    R_rho = zeros(chN,1); %α�������������,m^2
    R_rhodot = zeros(chN,1); %α���ʲ�����������,(m/s)^2
    for k=1:chN
        channel = obj.GPS.channels(k);
        if channel.state==2
            quality(k) = channel.quality;
            R_rho(k) = (sqrt(channel.codeVar.D)*0.12*Lco + 1.2*(1+16*(0.5-ele(k)/180)^3))^2;
            R_rhodot(k) = channel.carrVar.D*(6.15*Lca)^2;
        end
    end
    svGPS = [satmeasGPS, quality, R_rho, R_rhodot]; %���ź��������۵����ǲ�����Ϣ
    %---------------------------------------------------------------------%
    sv = svGPS(svGPS(:,9)>=1,[1:8,10,11]); %ѡ�ź�������Ϊ0������
    satnavGPS = satnavSolveWeighted(sv, obj.rp);
end
if obj.BDSflag==1
    satmeasBDS = obj.get_satmeasBDS; %���ǲ�����Ϣ
    [~, ele] = aziele_xyz(satmeasBDS(:,1:3), obj.pos); %���Ǹ߶Ƚ�
    %---------------------------------------------------------------------%
    chN = obj.BDS.chN;
    quality = zeros(chN,1); %�ź�����
    R_rho = zeros(chN,1); %α�������������,m^2
    R_rhodot = zeros(chN,1); %α���ʲ�����������,(m/s)^2
    for k=1:chN
        channel = obj.BDS.channels(k);
        if channel.state==2
            quality(k) = channel.quality;
            R_rho(k) = (sqrt(channel.codeVar.D)*0.12*Lco + 1.2*(1+16*(0.5-ele(k)/180)^3))^2;
            R_rhodot(k) = channel.carrVar.D*(6.15*Lca)^2;
        end
    end
    svBDS = [satmeasBDS, quality, R_rho, R_rhodot]; %���ź��������۵����ǲ�����Ϣ
    %---------------------------------------------------------------------%
    sv = svBDS(svBDS(:,9)>=1,[1:8,10,11]); %ѡ�ź�������Ϊ0������
    satnavBDS = satnavSolveWeighted(sv, obj.rp);
end

% ���ǵ�������
if obj.GPSflag==1 && obj.BDSflag==0
    satnav = satnavGPS;
elseif obj.GPSflag==0 && obj.BDSflag==1
    satnav = satnavBDS;
elseif obj.GPSflag==1 && obj.BDSflag==1
    sv = [svGPS(svGPS(:,9)>=1,[1:8,10,11]); svBDS(svBDS(:,9)>=1,[1:8,10,11])];
    satnav = satnavSolveWeighted(sv, obj.rp);
end
dtr = satnav(13); %���ջ��Ӳ�,s
dtv = satnav(14); %���ջ���Ƶ��,s/s

%%
% ���½��ջ�λ���ٶ�
if ~isnan(satnav(1))
    obj.pos = satnav(1:3);
    obj.rp  = satnav(4:6);
    obj.vel = satnav(7:9);
    obj.vp  = satnav(10:12);
end

% ���ջ�ʱ������
if ~isnan(dtr)
    T = obj.dtpos/1000; %��λʱ����,s
    obj.deltaFreq = obj.deltaFreq + 10*dtv*T;
    obj.ta = obj.ta - sec2smu(10*dtr*T);
end

% ���ݴ洢
obj.ns = obj.ns+1; %ָ��ǰ�洢��
m = obj.ns;
obj.storage.ta(m) = obj.tp * [1;1e-3;1e-6]; %��λʱ��,s
obj.storage.df(m) = obj.deltaFreq;
obj.storage.satnav(m,:) = satnav([1,2,3,7,8,9,13,14]);
if obj.GPSflag==1
    obj.storage.satnavGPS(m,:) = satnavGPS([1,2,3,7,8,9,13,14]);
    obj.storage.qualGPS(m,:) = svGPS(:,9);
end
if obj.BDSflag==1
    obj.storage.satnavBDS(m,:) = satnavBDS([1,2,3,7,8,9,13,14]);
    obj.storage.qualBDS(m,:) = svBDS(:,9);
end
obj.storage.pos(m,:) = obj.pos;
obj.storage.vel(m,:) = obj.vel;

% �����´ζ�λʱ��
obj.tp = timeCarry(obj.tp + [0,obj.dtpos,0]);

end
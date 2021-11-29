function pos_normal(obj)
% ������λ

% ��ȡ���ǲ�����Ϣ
[satpv, satmeas] = obj.get_satmeas;

% �߶Ƚ���������
[~, ele] = aziele_xyz(satpv(:,1:3), obj.pos); %���Ǹ߶Ƚ�
eleError = 5*(1-1./(1+exp(-((ele-30)/5)))); %S����(Sigmoid����) 1/(1+e^-x)

% ���ǵ�������(��Ȩ)
anN = obj.anN;
chN = obj.chN;
CN0 = zeros(chN,anN); %�����(ÿ����һ������)
R_rho = zeros(chN,anN); %α�������������,m^2
R_rhodot = zeros(chN,anN); %α���ʲ�����������,(m/s)^2
R_phase = zeros(chN,anN); %�ز���λ������������,(circ)^2
for m=1:anN
    for k=1:chN
        channel = obj.channels(k,m);
        if channel.state==2
            CN0(k,m) = channel.CN0;
            R_rho(k,m) = (sqrt(channel.varValue(1))+eleError(k))^2;
            R_rhodot(k,m) = channel.varValue(2);
            R_phase(k,m) = channel.varValue(4);
        end
    end
end
svIndex = CN0>=obj.CN0Thr.strong; %ѡ��(��������)
sv = [satpv, satmeas{1}(:,1:2), R_rho(:,1), R_rhodot(:,1)]; %����1
satnav = satnavSolveWeighted(sv(svIndex(:,1),:), obj.rp);
dtr = satnav(13); %���ջ��Ӳ�,s
dtv = satnav(14); %���ջ���Ƶ��,s/s

% ���½��ջ�λ���ٶ�
if ~isnan(satnav(1))
    obj.pos = satnav(1:3);
    obj.rp  = satnav(4:6);
    obj.vel = satnav(7:9);
    obj.vp  = satnav(10:12);
    obj.geogInfo = geogInfo_cal(obj.pos, obj.vel);
end

% ���ջ�ʱ������
if ~isnan(dtr)
    T = obj.dtpos/1000; %��λʱ����,s
    tv_corr = 10*dtv*T; %��Ƶ��������
    tr_corr = 10*dtr*T; %�Ӳ�������
    obj.deltaFreq = obj.deltaFreq + tv_corr;
    obj.ta = obj.ta - sec2smu(tr_corr);
    obj.clockError = obj.clockError + tr_corr; %�ۼ��Ӳ�������
end

% ���ݴ洢
obj.ns = obj.ns+1; %ָ��ǰ�洢��
k = obj.ns;
obj.storage.ta(k) = obj.tp * [1;1e-3;1e-6]; %��λʱ��,s
obj.storage.df(k) = obj.deltaFreq;
obj.storage.satpv(:,:,k) = satpv;
for m=1:anN
    obj.storage.satmeas(:,1:3,k,m) = satmeas{m};
    obj.storage.satmeas(:,4,k,m) = R_rho(:,m);
    obj.storage.satmeas(:,5,k,m) = R_rhodot(:,m);
    obj.storage.satmeas(:,6,k,m) = R_phase(:,m);
    obj.storage.satmeas(:,7,k,m) = CN0(:,m);
    obj.storage.svsel(:,1,k,m) = svIndex(:,m) + svIndex(:,m);
end
obj.storage.satnav(k,:) = satnav([1,2,3,7,8,9,13,14]);
obj.storage.pos(k,:) = obj.pos;
obj.storage.vel(k,:) = obj.vel;

% �����´ζ�λʱ��
obj.tp = timeCarry(obj.tp + [0,obj.dtpos,0]);

end
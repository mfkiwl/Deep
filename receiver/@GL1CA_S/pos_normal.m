function pos_normal(obj)
% ������λ

% ��ȡ���ǲ�����Ϣ
satmeas = obj.get_satmeas;

% ���ǵ�������(����Ȩ)
% svIndex = ~isnan(satmeas(:,1)); %ѡ��
% satnav = satnavSolve(satmeas(svIndex,:), obj.rp);
% dtr = satnav(13); %���ջ��Ӳ�,s
% dtv = satnav(14); %���ջ���Ƶ��,s/s

% �߶Ƚ���������
[~, ele] = aziele_xyz(satmeas(:,1:3), obj.pos); %���Ǹ߶Ƚ�
eleError = 5*(1-1./(1+exp(-((ele-30)/5))));

% ���ǵ�������(��Ȩ)
chN = obj.chN;
CN0 = zeros(chN,1); %�����
R_rho = zeros(chN,1); %α�������������,m^2
R_rhodot = zeros(chN,1); %α���ʲ�����������,(m/s)^2
for k=1:chN
    channel = obj.channels(k);
    if channel.state==2
        CN0(k) = channel.CN0;
        R_rho(k) = (sqrt(channel.varValue(1))+eleError(k))^2;
        R_rhodot(k) = channel.varValue(2);
    end
end
sv = [satmeas, R_rho, R_rhodot];
svIndex = CN0>=37; %ѡ��
satnav = satnavSolveWeighted(sv(svIndex,:), obj.rp);
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
    obj.deltaFreq = obj.deltaFreq + 10*dtv*T;
    obj.ta = obj.ta - sec2smu(10*dtr*T);
end

% ���ݴ洢
obj.ns = obj.ns+1; %ָ��ǰ�洢��
m = obj.ns;
obj.storage.ta(m) = obj.tp * [1;1e-3;1e-6]; %��λʱ��,s
obj.storage.df(m) = obj.deltaFreq;
obj.storage.satmeas(:,:,m) = sv; %satmeas;
obj.storage.satnav(m,:) = satnav([1,2,3,7,8,9,13,14]);
obj.storage.svsel(m,:) = svIndex;
obj.storage.pos(m,:) = obj.pos;
obj.storage.vel(m,:) = obj.vel;

% �����´ζ�λʱ��
obj.tp = timeCarry(obj.tp + [0,obj.dtpos,0]);

end
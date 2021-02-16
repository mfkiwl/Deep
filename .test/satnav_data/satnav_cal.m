% ����һ��α��Ͷ����ղ���ֵ,�������ǵ�������
% ephe0:������������,ÿ��һ������,5~25��Ϊ��Ч��������
% iono:8����������
% time:���ջ�ʱ��,[s,ms,us]
% rho:α������,32��,ÿ��һ������,�����ݵ�ΪNaN
% rhodot:����������(��α��仯���෴),32��,ÿ��һ������,�����ݵ�ΪNaN

c = 299792458;
f0 = 1575.42e6;
lla = [38.04643, 114.43583, 63]; %����λ��
rp = lla2ecef(lla);
vp = [0,0,0];
iono = NaN(1,8);

satnav = zeros(N,14); %�������

% p0 = [38.04647, 114.43595, 81];
% rp0 = lla2ecef(p0);
% rho0 = NaN(N,32);
% rhodot0 = NaN(N,32);

for k=1:N
    tr = time(k,:); %����ʱ��
    svList = find(~isnan(rho(k,:)));
    svList(svList==11) = []; %11������û������
    svN = length(svList);
    sv = zeros(svN,8);
    for m=1:svN
        PRN = svList(m);
        tt = rho(k,PRN) / c; %����ʱ��
        doppler = rhodot(k,PRN) / f0; %��һ��������
        te0 = timeCarry(tr-sec2smu(tt)); %����ʱ��,[s,ms,us]
        [rsvs, corr] = LNAV.rsvs_emit(ephe0(PRN,5:25), te0, rp, vp, iono, lla);
        rho_rhodot = satmeasCorr(tt, doppler, corr);
        sv(m,1:6) = rsvs;
        sv(m,7:8) = rho_rhodot;
    end
    satnav(k,:) = satnavSolve(sv, rp); %���ǵ�������
    
%     [rho0(k,svList), rhodot0(k,svList), ~] = rho_rhodot_cal_ecef(sv(:,1:3), sv(:,4:6), rp0, [0,0,0]);
end

% rhodot0 = -rhodot0/c*f0;
% drho = rho - rho0;
% drhodot = rhodot - rhodot0;
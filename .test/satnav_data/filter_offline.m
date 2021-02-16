% �����˲�
% α����������Ŵ�1e6,λ����ƽ��,˵���ٶȶ�
% α����������Ŵ�1e2,λ��Ư,˵����������Ӳ

c = 299792458;
f0 = 1575.42e6;
lla = [38.04643, 114.43583, 63]; %����λ��
rp = lla2ecef(lla);
vp = [0,0,0];
iono = NaN(1,8);

satnav = NaN(N,14); %�������
filternav = NaN(N,11); %�˲����
Poutput = NaN(N,11); %P��

para.dt = 1; %s
para.p0 = [38.0464248964929,114.435964910470,78.1216213665903];
para.v0 = [0,0,0];
para.P0_pos = 5; %m
para.P0_vel = 1; %m/s
para.P0_acc = 1; %m/s^2
para.P0_dtr = 2e-8; %s
para.P0_dtv = 3e-9; %s/s
para.Q_pos = 10*0;
para.Q_vel = 0;
para.Q_acc = 1e-4;
para.Q_dtr = 1e-8*1; %�Ӳ�仯������Ƶ�ƥ��ʱ,���ֵ����Ϊ0
para.Q_dtv = 1e-9;
filter = filter_sat(para);

filter.dtr = 5.80155265861624e-05;
filter.dtv = 4.25162735298042e-07;

for k=20:N %����ͷ��ʼ
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
    
    filter.run(sv, true(svN,1), true(svN,1));
    filternav(k,1:3) = filter.pos;
    filternav(k,4:6) = filter.vel;
    filternav(k,7:9) = filter.acc;
    filternav(k,10) = filter.dtr;
    filternav(k,11) = filter.dtv;
    Poutput(k,:) = sqrt(diag(filter.P));
end
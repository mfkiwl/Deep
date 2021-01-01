function rho_rhodot = satmeasCorr(tt, doppler, corr)
% �Բ������źŴ���ʱ��Ͷ����ս���У��,�õ�α��α����
% tt:�źŴ���ʱ��travel time,s
% dpppler:��һ��������,������,df/f0
% corr:У����,�ṹ��
% rho_rhodot:[α��,α����],m,m/s

c = 299792458;

tt = tt + corr.dtsv + corr.dtrel - corr.dtsagnac - corr.TGD - corr.dtiono;
rho = tt*c;

df = -doppler + corr.dfsv + corr.dfrel - corr.dfsagnac; %dopplerΪ��,��Ծ����С,����ȡ����
rhodot = df*c;

rho_rhodot = [rho, rhodot];

end
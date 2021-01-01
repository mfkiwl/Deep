function iono_24h(filepath, date, p, zone, eleMask)
% ����24h�����У����
% ��ֹ�߶Ƚ�ԽС,�����У�����ķ�ֵԽ��
% filepath:�����洢��·��,��β����\
% date:�����ַ���,'yyyy-mm-dd'
% p:���ջ�λ��,γ����,deg
% zone:ʱ��,������Ϊ��,������Ϊ��
% eleMask:��ֹ�߶Ƚ�,deg
% �ο�BDS.constellation

% ��ȡ����
filename = GPS.ephemeris.download(filepath, date);
ephemeris = RINEX.read_N2(filename);

% ��ȡ�����ļ��ĵ�һ������
ephe = NaN(32,16);
for k=1:32
    if isempty(ephemeris.sv{k})
        continue
    end
    ephe(k,1) = ephemeris.sv{k}(1).toe;
    ephe(k,2) = ephemeris.sv{k}(1).sqa;
    ephe(k,3) = ephemeris.sv{k}(1).e;
    ephe(k,4) = ephemeris.sv{k}(1).dn;
    ephe(k,5) = ephemeris.sv{k}(1).M0;
    ephe(k,6) = ephemeris.sv{k}(1).omega;
    ephe(k,7) = ephemeris.sv{k}(1).Omega0;
    ephe(k,8) = ephemeris.sv{k}(1).Omega_dot;
    ephe(k,9) = ephemeris.sv{k}(1).i0;
    ephe(k,10) = ephemeris.sv{k}(1).i_dot;
    ephe(k,11) = ephemeris.sv{k}(1).Cus;
    ephe(k,12) = ephemeris.sv{k}(1).Cuc;
    ephe(k,13) = ephemeris.sv{k}(1).Crs;
    ephe(k,14) = ephemeris.sv{k}(1).Crc;
    ephe(k,15) = ephemeris.sv{k}(1).Cis;
    ephe(k,16) = ephemeris.sv{k}(1).Cic;
end
PRN = find(~isnan(ephe(:,1))); %�����ݵ����Ǻ�
ephe = ephe(PRN,:); %ɾ�������ݵ���

% ��ȡ�����ļ��еĵ�������
iono = [ephemeris.alpha, ephemeris.beta];

% ��ʼʱ��
c = datevec(date,'yyyy-mm-dd'); %ʱ��ʸ��
t = UTC2GPS(c, zone); %[week,second]
ts = t(2); %ֻȡ����

% ����
n = 30*24; %�������,2����һ��
svN = length(PRN); %���Ǹ���
dtiono = NaN(n,svN);
for k=1:n
    rs = LNAV.rs_ephe(ephe, ts);
    [azi, ele] = aziele_xyz(rs, p); %�����������Ƿ�λ�Ǹ߶Ƚ�
    for i=1:svN
        if ele(i)>eleMask %�߶Ƚ�Ҫ���ڽ�ֹ�߶Ƚ�
            dtiono(k,i) = Klobuchar1(iono, azi(i), ele(i), p(1), p(2), ts);
        end
    end
    ts = ts+120; %��2����
end
dtiono = dtiono*299792458; %ת���ɾ���

% ��ͼ
figure('Name','iono_24h')
hold on
grid on
t = (0:n-1)/30; %ʱ�������,��λ:Сʱ
for k=1:svN
    f = plot(t,dtiono(:,k), 'Color',[0,0.447,0.741], 'LineWidth',1);
    c = uicontextmenu;
    f.UIContextMenu = c;
    uimenu(c, 'Text',sprintf('%d',PRN(k))); %����Ҽ���ʾ���Ǳ��
end
set(gca, 'XLim',[0,24])
set(gca, 'YLim',[0,12])

end
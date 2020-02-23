function ax = constellation(filepath, sl, zone, p, ax)
% ��ָ��ʱ���BDS����ͼ,���Խ���ͼ����,������ϵͳ����ͼ�ϵ���
% filepath:�����洢��·��,��β����\
% c:[year, mon, day, hour, min, sec], Date vectors
% zone:ʱ��,������Ϊ��,������Ϊ��
% p:γ����,deg
% ax:��������

% ��ȡ����(Ϊ��֤ȡ������,����ǰһ�������)
c0 = sl;
c0(4) = c0(4) - zone - 24; %����Сʱ,���ں�����
date = datestr(c0,'yyyy-mm-dd'); %�õ�ʱ���ַ���
filename = BDS.ephemeris.download(filepath, date);
ephe = RINEX.read_B303(filename);

% ��ȡ�����ļ������һ������
ephemeris = NaN(63,16);
for k=1:63
    if isempty(ephe.sv{k})
        continue
    end
    ephemeris(k,1) = ephe.sv{k}(end).toe;
    ephemeris(k,2) = ephe.sv{k}(end).sqa;
    ephemeris(k,3) = ephe.sv{k}(end).e;
    ephemeris(k,4) = ephe.sv{k}(end).dn;
    ephemeris(k,5) = ephe.sv{k}(end).M0;
    ephemeris(k,6) = ephe.sv{k}(end).omega;
    ephemeris(k,7) = ephe.sv{k}(end).Omega0;
    ephemeris(k,8) = ephe.sv{k}(end).Omega_dot;
    ephemeris(k,9) = ephe.sv{k}(end).i0;
    ephemeris(k,10) = ephe.sv{k}(end).i_dot;
    ephemeris(k,11) = ephe.sv{k}(end).Cus;
    ephemeris(k,12) = ephe.sv{k}(end).Cuc;
    ephemeris(k,13) = ephe.sv{k}(end).Crs;
    ephemeris(k,14) = ephe.sv{k}(end).Crc;
    ephemeris(k,15) = ephe.sv{k}(end).Cis;
    ephemeris(k,16) = ephe.sv{k}(end).Cic;
end
SV = find(~isnan(ephemeris(:,1))); %�����ݵ����Ǻ�
ephemeris(isnan(ephemeris(:,1)),:) = []; %ɾ�������ݵ���

% ʹ�����������������Ƿ�λ�Ǹ߶Ƚ�
t = UTC2BDT(sl, zone); %[week,second]
aziele = aziele_ephemeris(ephemeris, t(2), p); %[azi,ele]

% ��ȡ�߶ȽǴ���0������
index = find(aziele(:,2)>0); %�߶ȽǴ���0���к�
PRN = SV(index,1);
azi = mod(aziele(index,1),360)/180*pi; %��λ��ת�ɻ���,0~360��
ele = aziele(index,2);

% ����������
if ~exist('ax','var')
    figure
    ax = polaraxes; %������������
    ax.NextPlot = 'add'; %hold on
    ax.Clipping = 'off'; %�رռ��й���,�������Ƴ�������ʱ������ʾ
    ax.RLim = [0,90]; %�߶ȽǷ�Χ
    ax.RDir = 'reverse'; %�߶Ƚ�������90��
%     ax.RTick = [0,15,30,45,60,75,90]; %�߶Ƚǿ̶�
    ax.ThetaDir = 'clockwise'; %˳ʱ�뷽λ������
    ax.ThetaZeroLocation = 'top'; %��λ��0����
    title(sprintf('%d-%02d-%02d %02d:%02d:%02d UTC%+d', sl, zone))
    % ����һ��������,�ı�߶Ƚ���ʾ��Χ
    sl = uicontrol;
    sl.Style = 'slider';
    sl.Position = [15,15,120,15];
    sl.Max = 80;
    sl.Min = 0;
    sl.SliderStep = [2,8]/80;
    sl.Callback = @changeEleRange;
end
    function changeEleRange(src, ~)
        ax.RLim = [floor(src.Value),90];
    end

% ��ͼ
for k=1:length(PRN)
    if ele(k)<10 %�͸߶Ƚ�����,͸��
        polarscatter(ax, azi(k),ele(k), 220, 'MarkerFaceColor',[255,65,65]/255, ...
                     'MarkerEdgeColor',[127,127,127]/255, 'MarkerFaceAlpha',0.5)
        text(azi(k),ele(k),num2str(PRN(k)), 'HorizontalAlignment','center', ...
                                            'VerticalAlignment','middle')
    else
        polarscatter(ax, azi(k),ele(k), 220, 'MarkerFaceColor',[255,65,65]/255, ...
                     'MarkerEdgeColor',[127,127,127]/255)
        text(azi(k),ele(k),num2str(PRN(k)), 'HorizontalAlignment','center', ...
                                            'VerticalAlignment','middle')
    end
end

end
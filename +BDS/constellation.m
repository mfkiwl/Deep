function ax = constellation(filepath, c, zone, p, ax)
% ��ָ��ʱ���BDS����ͼ,���Խ���ͼ����,������ϵͳ����ͼ�ϵ���
% filepath:�����洢��·��,��β����\
% c:[year, mon, day, hour, min, sec]
% zone:ʱ��,������Ϊ��,������Ϊ��
% p:γ����,deg
% ax:��������

% ��ȡ����(Ϊ��֤ȡ������,����ǰһ�������)
c0 = c;
c0(4) = c0(4) - zone - 24; %����Сʱ,���ں�����
date = datestr(c0,'yyyy-mm-dd'); %�õ�ʱ���ַ���
filename = BDS.ephemeris.download(filepath, date);
ephemeris = RINEX.read_B303(filename);

% ��ȡ�����ļ������һ������
ephe = NaN(63,16);
for k=1:63
    if isempty(ephemeris.sv{k})
        continue
    end
    ephe(k,1) = ephemeris.sv{k}(end).toe;
    ephe(k,2) = ephemeris.sv{k}(end).sqa;
    ephe(k,3) = ephemeris.sv{k}(end).e;
    ephe(k,4) = ephemeris.sv{k}(end).dn;
    ephe(k,5) = ephemeris.sv{k}(end).M0;
    ephe(k,6) = ephemeris.sv{k}(end).omega;
    ephe(k,7) = ephemeris.sv{k}(end).Omega0;
    ephe(k,8) = ephemeris.sv{k}(end).Omega_dot;
    ephe(k,9) = ephemeris.sv{k}(end).i0;
    ephe(k,10) = ephemeris.sv{k}(end).i_dot;
    ephe(k,11) = ephemeris.sv{k}(end).Cus;
    ephe(k,12) = ephemeris.sv{k}(end).Cuc;
    ephe(k,13) = ephemeris.sv{k}(end).Crs;
    ephe(k,14) = ephemeris.sv{k}(end).Crc;
    ephe(k,15) = ephemeris.sv{k}(end).Cis;
    ephe(k,16) = ephemeris.sv{k}(end).Cic;
end
PRN = find(~isnan(ephe(:,1))); %�����ݵ����Ǻ�
ephe = ephe(PRN,:); %ɾ�������ݵ���

% ʹ�����������������Ƿ�λ�Ǹ߶Ƚ�
t = UTC2BDT(c, zone); %[week,second]
rs = D1.rs_ephe(ephe, t(2));
[azi, ele] = aziele_xyz(rs, p);

% ��ȡ�߶ȽǴ���0������
index = find(ele>0); %�߶ȽǴ���0���к�
PRN = PRN(index,1);
azi = azi(index)/180*pi; %��λ��ת�ɻ���
ele = ele(index);

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
    title(sprintf('%d-%02d-%02d %02d:%02d:%02d UTC%+d', c, zone))
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
    if ismember(PRN(k),[19:30,32:46]) %��������
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

end
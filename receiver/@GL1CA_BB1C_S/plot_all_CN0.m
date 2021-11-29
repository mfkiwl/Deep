function plot_all_CN0(obj)
% ������ͨ���������

% ��ɫ��
newcolors = [   0, 0.447, 0.741;
            0.850, 0.325, 0.098;
            0.929, 0.694, 0.125;
            0.494, 0.184, 0.556;
            0.466, 0.674, 0.188;
            0.301, 0.745, 0.933;
            0.635, 0.078, 0.184;
                1, 0.075, 0.651;
                1,     0,     0;
                0,     0,     1];

% GPS����
if obj.GPSflag==1
    figure('Name','GPS�����')
    colororder(newcolors) %������ɫ��
    axes
    box on
    hold on
    grid on
    for k=1:obj.GPS.chN
        channel = obj.GPS.channels(k);
        if any(~isnan(channel.storage.CN0)) %ֻ������������ݵ�ͨ��
            index = isnan(channel.storage.dataIndex) | channel.storage.bitFlag~=0;
            t = channel.storage.dataIndex(index) / channel.sampleFreq;
            plot(t, channel.storage.CN0(index), 'LineWidth',1, ...
                 'DisplayName',['PRN ',num2str(channel.PRN)])
        end
    end
    legend('Location','SouthWest')
    set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
    set(gca, 'YLim',[0,60])
end

% BDS����
if obj.BDSflag==1
    figure('Name','BDS�����')
    colororder(newcolors) %������ɫ��
    axes
    box on
    hold on
    grid on
    for k=1:obj.BDS.chN
        channel = obj.BDS.channels(k);
        if any(~isnan(channel.storage.CN0)) %ֻ������������ݵ�ͨ��
            index = isnan(channel.storage.dataIndex) | channel.storage.bitFlag~=0;
            t = channel.storage.dataIndex(index) / channel.sampleFreq;
            plot(t, channel.storage.CN0(index), 'LineWidth',1, ...
                 'DisplayName',['PRN ',num2str(channel.PRN)])
        end
    end
    legend('Location','SouthWest')
    set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
    set(gca, 'YLim',[0,60])
end

end
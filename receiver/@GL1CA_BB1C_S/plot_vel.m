function plot_vel(obj)
% ���ٶ����

if obj.ns==0 %û������ֱ���˳�
    return
end

% ʱ����
t = obj.storage.ta - obj.storage.ta(1);
t = t + obj.Tms/1000 - t(end);

%% ����ģʽ
if obj.state==1
    % ������GPS�����ٶ�
    if obj.GPSflag==1
        figure('Name','GPS�ٶ�')
        for k=1:3
            subplot(3,1,k)
            plot(t, obj.storage.satnavGPS(:,k+3))
            grid on
            set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
        end
    end
    % ���������������ٶ�
    if obj.BDSflag==1
        figure('Name','BDS�ٶ�')
        for k=1:3
            subplot(3,1,k)
            plot(t, obj.storage.satnavBDS(:,k+3), 'Color',[0.85,0.325,0.098])
            grid on
            set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
        end
    end
    % ��GPS�ͱ������Ͻ����ٶ�
    if obj.GPSflag==1 && obj.BDSflag==1
        figure('Name','GPS+BDS�ٶ�')
        for k=1:3
            subplot(3,1,k)
            plot(t, obj.storage.satnavGPS(:,k+3))
            hold on
            grid on
            plot(t, obj.storage.satnavBDS(:,k+3))
            plot(t, obj.storage.satnav(:,k+3))
            set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
        end
    end
end

%% �����ģʽ
if obj.state==3
    figure('Name','�ٶ�')
    for k=1:3
        subplot(3,1,k)
        plot(t, obj.storage.satnav(:,k+3))
        hold on
        grid on
        plot(t, obj.storage.vel(:,k), 'LineWidth',1)
        set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
    end
end

end
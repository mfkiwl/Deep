function plot_pos(obj)
% ��λ�����

if obj.ns==0 %û������ֱ���˳�
    return
end

% ʱ����
t = obj.storage.ta - obj.storage.ta(end) + obj.Tms/1000;

% ����ģʽ
if obj.state==1
    % ������GPS����λ��
    if obj.GPSflag==1
        figure('Name','GPSλ��')
        for k=1:3
            subplot(3,1,k)
            plot(t, obj.storage.satnavGPS(:,k))
            grid on
            set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
        end
    end
    % ��������������λ��
    if obj.BDSflag==1
        figure('Name','BDSλ��')
        for k=1:3
            subplot(3,1,k)
            plot(t, obj.storage.satnavBDS(:,k), 'Color',[0.85,0.325,0.098])
            grid on
            set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
        end
    end
    % ��GPS�ͱ������Ͻ����ٶ�
    if obj.GPSflag==1 && obj.BDSflag==1
        figure('Name','GPS+BDSλ��')
        for k=1:3
            subplot(3,1,k)
            plot(t, obj.storage.satnavGPS(:,k))
            hold on
            grid on
            plot(t, obj.storage.satnavBDS(:,k))
            plot(t, obj.storage.satnav(:,k))
            set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
        end
    end
end

% �����ģʽ
if obj.state==3
    figure('Name','λ��')
    for k=1:3
        subplot(3,1,k)
        plot(t, obj.storage.satnav(:,k))
        hold on
        grid on
        plot(t, obj.storage.pos(:,k), 'LineWidth',1)
        set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
    end
end

end
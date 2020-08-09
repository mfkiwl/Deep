function plot_vel(obj)
% ���ٶ����

%% ����ģʽ
if obj.state==1
    % ������GPS�����ٶ�
    if obj.GPSflag==1
        figure('Name','GPS�ٶ�')
        for k=1:3
            subplot(3,1,k)
            plot(obj.storage.satnavGPS(:,k+3))
            grid on
        end
    end
    % ���������������ٶ�
    if obj.BDSflag==1
        figure('Name','BDS�ٶ�')
        for k=1:3
            subplot(3,1,k)
            plot(obj.storage.satnavBDS(:,k+3), 'Color',[0.85,0.325,0.098])
            grid on
        end
    end
    % ��GPS�ͱ������Ͻ����ٶ�
    if obj.GPSflag==1 && obj.BDSflag==1
        figure('Name','GPS+BDS�ٶ�')
        for k=1:3
            subplot(3,1,k)
            plot(obj.storage.satnavGPS(:,k+3))
            hold on
            plot(obj.storage.satnavBDS(:,k+3))
            plot(obj.storage.satnav(:,k+3))
            grid on
        end
    end
end

%% �����ģʽ
if obj.state==3
    figure('Name','�ٶ�')
    for k=1:3
        subplot(3,1,k)
        plot(obj.storage.satnav(:,k+3))
        hold on
        grid on
        plot(obj.storage.vel(:,k), 'LineWidth',1)
    end
end

end
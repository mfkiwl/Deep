function plot_pos(obj)
% ��λ�����

if obj.GPSflag==1
    figure('Name','GPSλ��')
    for k=1:3
        subplot(3,1,k)
        plot(obj.storage.satnavGPS(:,k))
        grid on
    end
end

if obj.BDSflag==1
    figure('Name','BDSλ��')
    for k=1:3
        subplot(3,1,k)
        plot(obj.storage.satnavBDS(:,k), 'Color',[0.85,0.325,0.098])
        grid on
    end
end

if obj.GPSflag==1 && obj.BDSflag==1
    figure('Name','GPS+BDSλ��')
    for k=1:3
        subplot(3,1,k)
        plot(obj.storage.satnavGPS(:,k))
        hold on
        plot(obj.storage.satnavBDS(:,k))
        plot(obj.storage.satnav(:,k))
        grid on
    end
end

end
function plot_all_carrNco(obj)
% ������ͨ���ز�����Ƶ��

if obj.GPSflag==1
    for k=1:obj.GPS.chN
        channel = obj.GPS.channels(k);
        if channel.ns>0 %ֻ���и������ݵ�ͨ��
            channel.plot_carrNco;
        end
    end
end

if obj.BDSflag==1
    for k=1:obj.BDS.chN
        channel = obj.BDS.channels(k);
        if channel.ns>0 %ֻ���и������ݵ�ͨ��
            channel.plot_carrNco;
        end
    end
end

end
function plot_all_I_P(obj)
% ������ͨ��I_Pͼ

if obj.GPSflag==1
    for k=1:obj.GPS.chN
        channel = obj.GPS.channels(k);
        if channel.ns>0 %ֻ���и������ݵ�ͨ��
            channel.plot_I_P;
        end
    end
end

if obj.BDSflag==1
    for k=1:obj.BDS.chN
        channel = obj.BDS.channels(k);
        if channel.ns>0 %ֻ���и������ݵ�ͨ��
            channel.plot_I_P;
        end
    end
end

end
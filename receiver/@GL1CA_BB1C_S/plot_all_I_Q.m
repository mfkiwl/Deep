function plot_all_I_Q(obj)
% ������ͨ��I/Qͼ

if obj.GPSflag==1
    for k=1:obj.GPS.chN
        channel = obj.GPS.channels(k);
        if channel.ns>0 %ֻ���и������ݵ�ͨ��
            channel.plot_I_Q;
        end
    end
end

if obj.BDSflag==1
    for k=1:obj.BDS.chN
        channel = obj.BDS.channels(k);
        if channel.ns>0 %ֻ���и������ݵ�ͨ��
            channel.plot_I_Q;
        end
    end
end

end
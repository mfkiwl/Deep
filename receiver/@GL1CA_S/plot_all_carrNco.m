function plot_all_carrNco(obj)
% ������ͨ���ز�����Ƶ��

for k=1:obj.chN
    channel = obj.channels(k);
    if channel.ns>0 %ֻ���и������ݵ�ͨ��
        channel.plot_carrNco;
    end
end

end
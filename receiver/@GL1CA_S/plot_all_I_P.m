function plot_all_I_P(obj)
% ������ͨ��I_Pͼ

for k=1:obj.chN
    channel = obj.channels(k);
    if channel.ns>0 %ֻ���и������ݵ�ͨ��
        channel.plot_I_P;
    end
end

end
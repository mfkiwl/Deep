function plot_all_I_Q(obj)
% ������ͨ��I/Qͼ

for k=1:obj.chN
    channel = obj.channels(k);
    if channel.ns>0 %ֻ���и������ݵ�ͨ��
        channel.plot_I_Q;
    end
end

end
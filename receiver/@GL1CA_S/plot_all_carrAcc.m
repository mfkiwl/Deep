function plot_all_carrAcc(obj)
% ������ͨ���ز����ٶ�

for k=1:obj.chN
    channel = obj.channels(k);
    if channel.ns>0 %ֻ���и������ݵ�ͨ��
        channel.plot_carrAcc;
    end
end

end
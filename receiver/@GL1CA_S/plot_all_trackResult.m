function plot_all_trackResult(obj)
% ��ʾ����ͨ�����ٽ��

for k=1:obj.chN
    channel = obj.channels(k);
    if channel.ns>0 %ֻ���и������ݵ�ͨ��
        plot_trackResult(channel);
    end
end

end
function trackProcess(obj)
% ���ٹ���

for m=1:obj.anN
    for k=1:obj.chN
        channel = obj.channels(k,m);
        if channel.state==0 %���ͨ��δ����,��������
            continue
        end
        while 1
            %----�ж��Ƿ��������ĸ�������
            if mod(obj.buffHead-channel.trackDataHead,obj.buffSize)>(obj.buffSize/2)
                break
            end
            %----�źŴ���
            n1 = channel.trackDataTail;
            n2 = channel.trackDataHead;
            if n2>n1
                channel.track(obj.buffI{m}(n1:n2), obj.buffQ{m}(n1:n2));
            else
                channel.track([obj.buffI{m}(n1:end),obj.buffI{m}(1:n2)], [obj.buffQ{m}(n1:end),obj.buffQ{m}(1:n2)]);
            end
            %----������������
            ionoflag = channel.parse;
            %----��ȡ�����У������
            if ionoflag==1
                obj.iono = channel.iono;
            end
        end
    end
end

end
function trackProcessGPS(obj)
% GPS���ٹ���

for k=1:obj.GPS.chN
    channel = obj.GPS.channels(k);
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
            channel.track(obj.buffI(n1:n2), obj.buffQ(n1:n2), obj.deltaFreq);
        else
            channel.track([obj.buffI(n1:end),obj.buffI(1:n2)], ...
                          [obj.buffQ(n1:end),obj.buffQ(1:n2)], obj.deltaFreq);
        end
        %----������������
        ionoflag = channel.parse;
        %----��ȡ�����У������
        if ionoflag==1
            obj.GPS.iono = channel.iono;
        end
    end
end

end
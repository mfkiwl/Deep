function channel_deep(obj)
% ͨ���л�����ϸ��ٻ�·

if obj.deepMode==1
    for k=1:obj.chN
        channel = obj.channels(k);
        if channel.state==2
            channel.state = 3;
            channel.codeMode = 2; %�����뻷
            channel.codeDiscBuffPtr = 0; %����������������
        end
    end
elseif obj.deepMode==2
    for k=1:obj.chN
        channel = obj.channels(k);
        if channel.state==2
            channel.state = 3;
            channel.codeMode = 2; %�����뻷
            channel.carrMode = 3; %�����ز���
            channel.codeDiscBuffPtr = 0; %����������������
        end
    end
end

end
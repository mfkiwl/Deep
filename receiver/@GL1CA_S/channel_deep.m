function channel_deep(obj)
% ͨ���л�����ϸ��ٻ�·

switch obj.deepMode
    case 1
        for k=1:obj.chN
            channel = obj.channels(k);
            if channel.state==2
                channel.state = 3;
                channel.codeMode = 2; %�����뻷
                channel.markCurrStorage;
            end
        end
    case 2
        
end

end
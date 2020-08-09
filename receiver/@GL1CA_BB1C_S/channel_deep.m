function channel_deep(obj)
% ͨ���л�����ϸ��ٻ�·

%% GPS����
if obj.GPSflag==1
    if obj.deepMode==1
        for k=1:obj.GPS.chN
            channel = obj.GPS.channels(k);
            if channel.state==2
                channel.state = 3;
                channel.codeMode = 2; %�����뻷
                channel.markCurrStorage;
            end
        end
    elseif obj.deepMode==2
        for k=1:obj.GPS.chN
            channel = obj.GPS.channels(k);
            if channel.state==2
                channel.state = 3;
                channel.codeMode = 2; %�����뻷
                channel.carrMode = 3; %�����ز���
                channel.markCurrStorage;
            end
        end
    end
end

%% BDS����
if obj.BDSflag==1
    if obj.deepMode==1
        for k=1:obj.BDS.chN
            channel = obj.BDS.channels(k);
            if channel.state==2
                channel.state = 3;
                channel.codeMode = 2; %�����뻷
                channel.markCurrStorage;
            end
        end
	elseif obj.deepMode==2
        for k=1:obj.BDS.chN
            channel = obj.BDS.channels(k);
            if channel.state==2
                channel.state = 3;
                channel.codeMode = 2; %�����뻷
                channel.carrMode = 3; %�����ز���
                channel.markCurrStorage;
            end
        end
    end
end

end
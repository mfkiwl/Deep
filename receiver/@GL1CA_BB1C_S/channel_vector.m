function channel_vector(obj)
% ͨ���л�ʸ�����ٻ�·

%% GPS����
if obj.GPSflag==1
    if obj.vectorMode==1
        for k=1:obj.GPS.chN
            channel = obj.GPS.channels(k);
            if channel.state==2
                channel.state = 3;
                channel.codeMode = 2; %�뿪��
                channel.discBuffPtr = 0; %��������������
            end
        end
    elseif obj.vectorMode==2
        for k=1:obj.GPS.chN
            channel = obj.GPS.channels(k);
            if channel.state==2
                channel.state = 3;
                channel.codeMode = 2; %�뿪��
                channel.carrMode = 3; %ʸ���������໷
                channel.discBuffPtr = 0; %��������������
            end
        end
    end
end

%% BDS����
if obj.BDSflag==1
    if obj.vectorMode==1
        for k=1:obj.BDS.chN
            channel = obj.BDS.channels(k);
            if channel.state==2
                channel.state = 3;
                channel.codeMode = 2; %�뿪��
                channel.discBuffPtr = 0; %��������������
            end
        end
	elseif obj.vectorMode==2
        for k=1:obj.BDS.chN
            channel = obj.BDS.channels(k);
            if channel.state==2
                channel.state = 3;
                channel.codeMode = 2; %�뿪��
                channel.carrMode = 3; %ʸ���������໷
                channel.discBuffPtr = 0; %��������������
            end
        end
    end
end

end
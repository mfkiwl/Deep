function channel_vector(obj)
% ͨ���л�ʸ�����ٻ�·

if obj.vectorMode==1 %ֻ���뻷ʸ������
    for k=1:obj.chN
        channel = obj.channels(k);
        if channel.state==2
            channel.state = 3;
            channel.codeMode = 2; %�뿪��
            channel.codeDiscBuffPtr = 0; %����������������
        end
    end
elseif obj.vectorMode==2 %�뻷���ز�������ʸ������,�ز�������
    for k=1:obj.chN
        channel = obj.channels(k);
        if channel.state==2
            channel.state = 3;
            channel.codeMode = 2; %�뿪��
            channel.carrMode = 3; %ʸ���������໷
            channel.codeDiscBuffPtr = 0; %����������������
        end
    end
elseif obj.vectorMode==3 %�뻷���ز�������ʸ������,�ز�������
    for k=1:obj.chN
        channel = obj.channels(k);
        if channel.state==2
            channel.state = 3;
            channel.codeMode = 2; %�뿪��
            channel.carrMode = 5; %ʸ���������໷
            channel.codeDiscBuffPtr = 0; %����������������
        end
    end
end

end
function adjust_coherentTime(obj, policy)
% ������ɻ���ʱ��
% policy:��������

% ����1,��������ȵ���
% С��30dB��Hzʹ��20ms����ʱ��
% 30~37dB��Hzʹ��5ms����ʱ��
% ����37dB��Hzʹ��1ms����ʱ��
if policy==1
    if obj.CN0<30
        if obj.coherentN~=20
            obj.set_coherentTime(20);
        end
    elseif obj.CN0<37
        if obj.coherentN~=5
            obj.set_coherentTime(5);
        end
    else
        if obj.coherentN~=1
            obj.set_coherentTime(1);
        end
    end
    return
end

% ����2,ֻ�������ʱ����
if policy==2
    if obj.state==3
        if obj.CN0<37
            if obj.coherentN~=4
                obj.set_coherentTime(4);
            end
        else
            if obj.coherentN~=1
                obj.set_coherentTime(1);
            end
        end
    end
    return
end

end
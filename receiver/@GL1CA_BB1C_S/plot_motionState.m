function plot_motionState(obj)
% ���˶�״̬

if obj.ns==0 %û������ֱ���˳�
    return
end

% ʱ����
t = obj.storage.ta - obj.storage.ta(1);
t = t + obj.Tms/1000 - t(end);

%% �����ģʽ
if obj.state==3
    figure('Name','�˶�״̬')
    plot(t, vecnorm(obj.storage.imu(:,1:3),2,2)) %���ٶ�ģ��
    hold on
    grid on
    plot(t, obj.storage.motion) %�˶�״̬
    set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
end

end
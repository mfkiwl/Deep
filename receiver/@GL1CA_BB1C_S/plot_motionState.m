function plot_motionState(obj)
% ���˶�״̬

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
end

end
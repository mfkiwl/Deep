function plot_all_drho(obj)
% ������ͨ����α�����(α����ز���λ��Ӧ�ľ���)

if obj.ns==0 %û������ֱ���˳�
    return
end

% ʱ����
t = obj.storage.ta - obj.storage.ta(end) + obj.Tms/1000;

Lca = 0.190293672798365;
for k=1:length(obj.result.satmeasIndex) %ֻ�������������
    i = obj.result.satmeasIndex(k); %����
    PRN_str = ['GPS ',obj.result.satmeasPRN{k}];
    figure('Name',PRN_str)
    plot(t, obj.storage.satmeas{i}(:,7)-obj.storage.satmeas{i}(:,11)*Lca)
    grid on
    set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
end
    

end
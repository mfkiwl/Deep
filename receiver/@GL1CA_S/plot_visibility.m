function plot_visibility(obj)
% �����ǿɼ���

if all(obj.result.svnum(:,2)==0)
    return
end

% ʱ����
t = obj.storage.ta - obj.storage.ta(end) + obj.Tms/1000;

% ���ǿɼ���
svsel = double(obj.storage.svsel);
n = size(svsel,2); %ͨ������
for k=1:n
    index1 = svsel(:,k)~=0;
    index2 = svsel(:,k)==0;
    svsel(index1,k) = k;
    svsel(index2,k) = NaN;
end

% y���ǩ
label_str = cell(1,n);
for k=1:n
    label_str{k} = sprintf('G%d', obj.svList(k));
end

% ��ͼ
figure
plot(t,svsel, 'Color',[65,180,250]/255, 'LineWidth',10)
set(gca, 'YLim',[0,n+1])
yticks(1:n)
yticklabels(label_str)

end
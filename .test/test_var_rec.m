% ���Ե��Ƽ����ֵ,����
% �����㷨��ʱ������ʱ�������ڼ��������ɾ����½�

n = 100000; %�������
output = zeros(n,3);

% obj = mean_rec(1000);
obj = var_rec(1000);

for k=1:n
    x = 10 + randn*3;
    obj.update(x);
    output(k,1) = x;
    output(k,2) = obj.E;
    output(k,3) = sqrt(obj.D); %��׼��
end

disp([obj.E, obj.D])
disp([mean(obj.buff), var(obj.buff,1)])
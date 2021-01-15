% ����DLL��ͬ��·����������λ��׼��������ȵĹ�ϵ����(�̶�����ʱ��)
% �������ϵ��:A,a
% CN0--log10_sigma_Pcode������ֱ��,���ڲ�ͬ�Ļ�·����б�����,�������
% log10_sigma_Pcode = A*CN0 + B(Bn)
% �������뻷·�������Ϻ���Ϊ: B(Bn) = log10(a*Bn)/2
% 10^(B*2)��һ����ԭ���ֱ��
% ϵ��: A=-0.05, a=0.264
% ����λ��׼����㹫ʽ: 10^(-0.05*CN0) * sqrt(0.264*Bn)
% α��������׼����㹫ʽ: 10^(-0.05*CN0) * sqrt(0.264*Bn) * 300
% α������������㹫ʽ: 10^(-0.1*CN0) * (0.264*Bn) * 9e4
% �봦�������Ƶ���ݱȽ�ʱ,���ջ�Ӧ�ùر�ʱ������,�����ͨ����α��������

%% ����
Bn_table = 0.2:0.2:2; %��·�����
CN0_table = 28:0.5:60; %����ȱ�
T = 0.02; %����ʱ��(��ͬ����ʱ����������һ��,����ʱ�䳤����С)
n = 100000; %�������ݵ���

Bn_N = length(Bn_table); %��·�������
CN0_N = length(CN0_table); %����ȸ���

result = zeros(CN0_N,Bn_N); %ͳ�ƽ��,ÿһ����һ�������,ÿһ����һ������

%% ����
for m=1:Bn_N %��������
    Bn = Bn_table(m); %����
    for w=1:CN0_N %���������
        CN0 = CN0_table(w); %�����
        [~, ~, Pout] = DLL2_cal(Bn, T, CN0, n);
        result(w,m) = std(Pout);
    end
end

%% ��ͼ
figure
for k=1:Bn_N
    semilogy(CN0_table, result(:,k))
    hold on
end
grid on
xlabel('����� (dB��Hz)')
ylabel('����λ��׼�� (��Ƭ)')
title('��ͬ��·����������λ��׼��������ȵĹ�ϵ����')

figure
for k=1:Bn_N
    semilogy(CN0_table, result(:,k)*300)
    hold on
end
grid on
xlabel('����� (dB��Hz)')
ylabel('α��������׼�� (m)')
title('��ͬ��·������α��������׼��������ȵĹ�ϵ����')

%% ���CN0--log10_sigma_Pcode����
result_log10 = log10(result);
coef = zeros(Bn_N,2); %ÿ����һ������
for k=1:Bn_N
    coef(k,:) = polyfit(CN0_table, result_log10(:,k), 1); %һ�ζ���ʽ���
end
A = mean(coef(:,1)); %б��

%% ���Bn--B����
B_Bn = coef(:,2)'; %ȡ������B

Y = 10.^(B_Bn*2); %��B_Bn���任
a = (Bn_table*Y') / (Bn_table*Bn_table'); %��С������б��

figure
plot(Bn_table, Y, '.', 'MarkerSize',12)
hold on
grid on
plot(Bn_table, a*Bn_table)
xlabel('��·���� (Hz)')
ylabel('10^B^*^2')
title('B�任�����Ͻ��')
legend('data', 'fit', 'Location','NorthWest')

figure
plot(Bn_table, B_Bn, '.', 'MarkerSize',12)
hold on
grid on
x = Bn_table(1):0.05:Bn_table(end); %��ȡ��һ��
plot(x, log10(a*x)/2)
xlabel('��·���� (Hz)')
ylabel('B')
title('B�任ǰ����Ͻ��')
legend('data', 'fit',  'Location','NorthWest')

%% ��ʾ���
disp(['A=',num2str(A),', a=',num2str(a)])
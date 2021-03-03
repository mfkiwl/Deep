% ��ͬ����ʱ�����������������׼��������ȵĹ�ϵ����
% �������ϵ��:A,a
% CN0--log10_sigma_disc������ֱ��,���ڲ�ͬ�Ļ���ʱ��б�����,�������
% log10_sigma_disc = A*CN0 + B(Tms)
% ��������������ʱ�����Ϻ���Ϊ: B(Tms) = -log10(a*Tms)/2
% 10^(-B*2)��һ����ԭ���ֱ��
% ϵ��: A=-0.05, a=0.008
% �������������׼����㹫ʽ: 10^(-0.05*CN0) / sqrt(0.008*Tms)

%% ����
d = 0.3; %����������,��Ƭ
CN0_table = 35:0.5:60; %����ȱ�
T_table = [1,2,4,5,10,20] * 0.001; %����ʱ���
n = 10000; %�������ݵ���

CN0_N = length(CN0_table); %����ȸ���
T_N = length(T_table); %����ʱ�����

result = zeros(CN0_N,T_N); %ͳ�ƽ��,ÿһ����һ�������,ÿһ����һ������ʱ��

%% ����
for m=1:T_N %��������ʱ��
    T = T_table(m); %����ʱ��
    for w=1:CN0_N %���������
        CN0 = CN0_table(w); %�����
        A = sqrt(2*T*10^(CN0/10)); %���ַ�ֵ
        noiseE = (randn(1,n) + randn(1,n)*1j) / sqrt(2); %��ǰ·������
        noiseL = (randn(1,n) + randn(1,n)*1j) / sqrt(2); %�ͺ�·������
        SE = abs(A*(1-d)+noiseE); %��ǰ·��ֵ
        SL = abs(A*(1-d)+noiseL); %�ͺ�·��ֵ
        e = (1-d) * (SE-SL) ./ (SE+SL);
%         SE = abs(A*(1-1.5*d)+noiseE); %��ǰ·��ֵ
%         SL = abs(A*(1-1.5*d)+noiseL); %�ͺ�·��ֵ
%         e = (11/30) * (SE-SL) ./ (SE+SL) / 2;
        result(w,m) = std(e);
    end
end

%% ��ͼ
figure
for k=1:T_N
    semilogy(CN0_table, result(:,k)) %ȡlog10������
    hold on
end
grid on
xlabel('����� (dB��Hz)')
ylabel('�������������׼�� (��Ƭ)')
title('��ͬ����ʱ�����������������׼��������ȵĹ�ϵ����')
legend('1ms','2ms','4ms','5ms','10ms','20ms')

%% ���CN0--log10_sigma_disc����
result_log10 = log10(result);
coef = zeros(T_N,2); %ÿ����һ������ʱ��
for k=1:T_N
    coef(k,:) = polyfit(CN0_table, result_log10(:,k), 1); %һ�ζ���ʽ���
end
A = mean(coef(:,1)); %б��

%% ���Tms--B����
Tms_table = T_table * 1000; %����ʱ����ms
B_Tms = coef(:,2)'; %ȡ������B

Y = 10.^(-B_Tms*2); %��B_Bn���任
a = (Tms_table*Y') / (Tms_table*Tms_table'); %��С������б��

figure
plot(Tms_table, Y, '.', 'MarkerSize',12)
hold on
grid on
plot(Tms_table, a*Tms_table)
xlabel('����ʱ�� (ms)')
ylabel('10^-^B^*^2')
title('B�任�����Ͻ��')
legend('data', 'fit', 'Location','NorthWest')

figure
plot(Tms_table, B_Tms, '.', 'MarkerSize',12)
hold on
grid on
x = Tms_table(1):0.2:Tms_table(end); %��ȡ��һ��
plot(x, -log10(a*x)/2)
xlabel('����ʱ�� (ms)')
ylabel('B')
title('B�任ǰ����Ͻ��')
legend('data', 'fit',  'Location','NorthEast')

%% ��ʾ���
disp(['A=',num2str(A),', a=',num2str(a)])
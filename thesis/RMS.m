% figure�����߾��������ͳ��
% �ȵ��Ӧ��ͼƬ,����1���������

clc
a = gca;
d = a.Children(1).YData;
ds = d(end-6666:end); %1333,6666
figure
plot(d)
rms = sqrt(sum(ds.^2)/length(ds))
function plot_I_Q(obj)
% ��I/Qͼ(���ݷ���I·,��Ƶ����Q·)

PRN_str = ['BDS ',sprintf('%d',obj.PRN)];
figure('Name',PRN_str)
plot(obj.storage.I_Q(1001:end,7), obj.storage.I_Q(1001:end,8), ...
     'LineStyle','none', 'Marker','.')
axis equal

end
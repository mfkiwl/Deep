function plot_svnum(obj)
% ���ɼ���������

if obj.ns==0 %û������ֱ���˳�
    return
end

% ʱ����
t = obj.storage.ta - obj.storage.ta(end) + obj.Tms/1000;

figure('Name','�ɼ���������')
if obj.GPSflag+obj.BDSflag==1
    plot(t, obj.result.svnumALL(:,2))
    grid on
    set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
elseif obj.GPSflag+obj.BDSflag==2
    svnum_table = table(t,obj.result.svnumGPS(:,2), ...
                          obj.result.svnumBDS(:,2), ...
                          obj.result.svnumALL(:,2), ...
                        'VariableNames',{'t','GPS','BDS','GPS+BDS'});
    stackedplot(svnum_table, 'XVariable','t')
    grid on
    set(gca, 'XLim',[0,ceil(obj.Tms/1000)])
end

end
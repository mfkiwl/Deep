function print_all_log(obj)
% ��ӡ����ͨ����־

disp('<----------------------------------------------------->')
for k=1:obj.chN
    obj.channels(k).print_log;
end

end
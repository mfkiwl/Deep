function print_log(obj)
% ��ӡͨ����־

fprintf('GPS %d\n', obj.PRN); %���Ǳ��,ʹ��\r\n���һ������
n = length(obj.log); %ͨ����־����
if n>0 %�����־������,���д�ӡ
    for k=1:n
        disp(obj.log(k))
    end
end
disp(' ') %��β��һ������

end
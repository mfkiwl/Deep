function clean_storage(obj)
% �������ݴ洢

% �Զ�ʶ�����г�,�μ�help-Generate Field Names from Variables
fields = fieldnames(obj.storage); %��ȡ���г���,Ԫ������
n = obj.ns + 1;
for k=1:length(fields)
    obj.storage.(fields{k})(n:end,:) = [];
end

end
function clean_storage(obj)
% �������ݴ洢

% ����ͨ���ڶ���Ĵ洢�ռ�
for k=1:obj.chN
    obj.channels(k).clean_storage;
end

% ��ȡ���г���,Ԫ������
fields = fieldnames(obj.storage);

% �������Ľ��ջ�����洢�ռ�
n = obj.ns + 1;
for k=1:length(fields)
    if size(obj.storage.(fields{k}),3)==1 %��ά�洢�ռ�
        obj.storage.(fields{k})(n:end,:) = [];
    else %��ά�洢�ռ�
        obj.storage.(fields{k})(:,:,n:end) = [];
    end
end

% �������ǲ�����Ϣ,Ԫ������,ÿ��ͨ��һ������
n = size(obj.storage.satmeas,3); %�洢Ԫ�ظ���
m = size(obj.storage.satmeas,2); %����
if n>0
    satmeas = cell(obj.chN,1);
    for k=1:obj.chN
        satmeas{k} = reshape(obj.storage.satmeas(k,:,:),m,n)';
    end
    obj.storage.satmeas = satmeas;
end

end
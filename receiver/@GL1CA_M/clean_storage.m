function clean_storage(obj)
% �������ݴ洢

% ����ͨ���ڶ���Ĵ洢�ռ�
for m=1:obj.anN
    for k=1:obj.chN
        obj.channels(k,m).clean_storage;
    end
end

% ��ȡ���г���,Ԫ������
fields = fieldnames(obj.storage);

% �������Ľ��ջ�����洢�ռ�
n = obj.ns + 1;
for k=1:length(fields)
    if ismatrix(obj.storage.(fields{k})) %��ά����
        obj.storage.(fields{k})(n:end,:) = [];
    else %�Ƕ�ά����
        obj.storage.(fields{k})(:,:,n:end,:) = [];
    end
end

% ��������λ���ٶ�
n = size(obj.storage.satpv,3); %�洢Ԫ�ظ���
if n>0
    satpv = cell(obj.chN,1);
    for k=1:obj.chN
        satpv{k} = reshape(obj.storage.satpv(k,:,:),6,n)';
    end
    obj.storage.satpv = satpv;
end

% �������ǲ�����Ϣ,Ԫ������,����ͨ��,��������
n = size(obj.storage.satmeas,3); %�洢Ԫ�ظ���
j = size(obj.storage.satmeas,2); %����
if n>0
    satmeas = cell(obj.chN,obj.anN);
    for m=1:obj.anN
        for k=1:obj.chN
            satmeas{k,m} = reshape(obj.storage.satmeas(k,:,:,m),j,n)';
        end
    end
    obj.storage.satmeas = satmeas;
end

% ����ѡ��
n = size(obj.storage.svsel,3); %�洢Ԫ�ظ���
j = size(obj.storage.svsel,1); %����
if n>0
    svsel = cell(1,obj.anN);
    for m=1:obj.anN
        svsel{m} = reshape(obj.storage.svsel(:,1,:,m),j,n)';
    end
    obj.storage.svsel = svsel;
end

end
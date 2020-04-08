function acqProcess(obj)
% �������

for k=1:obj.chN
    channel = obj.channels(k);
    if channel.state~=0 %���ͨ���Ѽ���,��������
        continue
    end
    n = channel.acqN; %�����������
    acqResult = channel.acq(obj.buffI((end-2*n+1):end), obj.buffQ((end-2*n+1):end));
    if ~isempty(acqResult) %����ɹ����ʼ��ͨ��
        channel.init(acqResult, obj.tms/1000*obj.sampleFreq);
    end
end

end
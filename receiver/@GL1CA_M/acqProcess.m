function acqProcess(obj)
% �������

for m=1:obj.anN
    for k=1:obj.chN
        channel = obj.channels(k,m);
        if channel.state~=0 %���ͨ���Ѽ���,��������
            continue
        end
        n = channel.acqN; %�����������
        acqResult = channel.acq(obj.buffI{m}((end-2*n+1):end), obj.buffQ{m}((end-2*n+1):end));
        if ~isempty(acqResult) %����ɹ����ʼ��ͨ��
            channel.init(acqResult, obj.tms/1000*obj.sampleFreq);
        end
    end
end

end
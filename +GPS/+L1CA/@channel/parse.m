function ionoflag = parse(obj)
% ������������
% �Ӳ��񵽽������ͬ��Ҫ500ms
% ����ͬ������Ҫ2s,��ʼѰ��֡ͷҪ��һ��ʱ��,��Ϊ�ȴ����ر߽絽��
% ����ͬ����ʼѰ��֡ͷ,����һ��������֡����У��֡ͷ,����6s,���12s
% ��֤֡ͷ��Ϳ���ȷ���뷢��ʱ��
% 6sһ����֡,30s��������һ��
% ����ͬ����������ӻ���ʱ��

ionoflag = 0; %�����ǰ����������֡�е�������,�ñ�־λ��1

obj.msgCnt = obj.msgCnt + 1; %������1

switch obj.msgStage %I,B,W,H,C,E
    case 'I' %����
        waitPLLstable;
    case 'B' %����ͬ��
        bitSync;
    case 'W' %�ȴ����ؿ�ʼ
        waitBitStart;
    otherwise %�Ѿ���ɱ���ͬ��
        obj.bitBuff(obj.msgCnt) = obj.I; %�����ػ����д���
        if obj.msgCnt==1 %��¼���ؿ�ʼ��־
            obj.storage.bitFlag(obj.ns) = obj.msgStage;
        end
        obj.SQI.run(obj.I, obj.Q); %�����ź�����
        obj.quality = obj.SQI.quality;
        obj.storage.quality(obj.ns) = obj.quality;
        if obj.msgCnt==obj.pointInt %������һ������
            obj.msgCnt = 0; %����������
            obj.frameBuffPtr = obj.frameBuffPtr + 1; %֡����ָ���1
            bit = (double(sum(obj.bitBuff(1:obj.pointInt))>0) - 0.5) * 2; %һ������,��1
            obj.frameBuff(obj.frameBuffPtr) = bit; %�����ػ������
            switch obj.msgStage
                case 'H' %Ѱ��֡ͷ
                    findFrameHead;
                case 'C' %У��֡ͷ
                    checkFrameHead;
                case 'E' %��������
                    parseEphemeris;
            end
        end
end

    %% �ȴ����໷�ȶ�
    function waitPLLstable
        if obj.carrMode~=2 %�����໷ģʽ����
            obj.msgCnt = 0;
            return
        end
        if obj.msgCnt==300 %��ʱ���˾���Ϊ�Ѿ��ȶ�
            obj.msgCnt = 0; %����������
            obj.msgStage = 'B'; %�������ͬ���׶�
            log_str = sprintf('Start bit synchronization at %.8fs', obj.dataIndex/obj.sampleFreq);
            obj.log = [obj.log; string(log_str)];
        end
    end

    %% ����ͬ��
    function bitSync
        if obj.I0*obj.I<0 %���ֵ�ƽ��ת
            index = mod(obj.msgCnt-1,20) + 1;
            obj.bitSyncTable(index) = obj.bitSyncTable(index) + 1; %ͳ�Ʊ��еĶ�Ӧλ��1
        end
        obj.I0 = obj.I;
        if obj.msgCnt==2000 %2s�����ͳ�Ʊ�,��ʱ��100������
            obj.I0 = 0; %I0�����Ͳ�����,������λ
            if max(obj.bitSyncTable)>10 && (sum(obj.bitSyncTable)-max(obj.bitSyncTable))<=2
                % ����ͬ���ɹ�,ȷ����ƽ��תλ��(��ƽ��ת�󶼷�����һ������)
                [~,obj.msgCnt] = max(obj.bitSyncTable); %������ֵ��Ϊͬ�������ֵ������
                obj.bitSyncTable = zeros(1,20); %����ͬ��ͳ�Ʊ�����
                obj.msgCnt = -obj.msgCnt + 1; %�������Ϊ1,�¸�I·����ֵ��Ϊ���ؿ�ʼ��
                obj.msgStage = 'W'; %�ȴ����ؿ�ʼ
                waitBitStart;
            else
                % ����ͬ��ʧ��,�ر�ͨ��
                obj.state = 0;
                obj.ns = obj.ns + 1; %���ݴ洢��һ��,�൱�ڼ�һ����ϵ�
                log_str = sprintf('***Bit synchronization failed at %.8fs', obj.dataIndex/obj.sampleFreq);
                obj.log = [obj.log; string(log_str)];
            end
        end
    end

    %% �ȴ����ؿ�ʼ
    function waitBitStart
        if obj.msgCnt==0
            obj.msgStage = 'H'; %����Ѱ��֡ͷ�׶�
            log_str = sprintf('Start find head at %.8fs', obj.dataIndex/obj.sampleFreq);
            obj.log = [obj.log; string(log_str)];
        end
    end

    %% Ѱ��֡ͷ
    function findFrameHead
        if obj.frameBuffPtr>=10 %������10������,ǰ��������У��
            if abs(obj.frameBuff(obj.frameBuffPtr+(-7:0))*[1;-1;-1;-1;1;-1;1;1])==8 %��⵽����֡ͷ
                obj.frameBuff(1:10) = obj.frameBuff(obj.frameBuffPtr+(-9:0)); %��֡ͷ��ǰ
                obj.frameBuffPtr = 10;
                obj.msgStage = 'C'; %����У��֡ͷ�׶�
            end
            if obj.frameBuffPtr==1502
                obj.frameBuffPtr = 0;
            end
        end
    end

    %% У��֡ͷ
    function checkFrameHead
        if obj.frameBuffPtr==310 %�洢��һ����֡,2+300+8
            if GPS.L1CA.wordCheck(obj.frameBuff(1:32))==1 && ...
               GPS.L1CA.wordCheck(obj.frameBuff(31:62))==1 && ...
               abs(obj.frameBuff(303:310)*[1;-1;-1;-1;1;-1;1;1])==8 %У��ͨ��
                % ��ȡ����ʱ��
                % frameBuff(32)Ϊ��һ�ֵ����һλ,У��ʱ���Ƶ�ƽ��ת,1��ʾ��ת,�μ�ICD-GPS���ҳ
                bits = -obj.frameBuff(32) * obj.frameBuff(33:49); %��ƽ��ת,31~47����
                bits = dec2bin(bits>0)'; %��1����ת��Ϊ01�ַ���
                TOW = bin2dec(bits); %01�ַ���ת��Ϊʮ������
                obj.tc0 = (TOW*6+0.16)*1000; %����α�����ڿ�ʼʱ��,ms,0.16=8/50,�Ѿ�����8������
                % TOWΪ��һ��֡��ʼʱ��,�μ�<����/GPS˫ģ������ջ�ԭ����ʵ�ּ���>96ҳ
                if ~isnan(obj.ephe(1)) %�����������,ֱ�Ӹ���ͨ��״̬
                    obj.state = 2;
                end
                obj.msgStage = 'E'; %������������׶�
                log_str = sprintf('Start parse ephemeris at %.8fs', obj.dataIndex/obj.sampleFreq);
                obj.log = [obj.log; string(log_str)];
            else %У��δͨ��
                for k=11:310 %���������������û��֡ͷ
                    if abs(obj.frameBuff(k+(-7:0))*[1;-1;-1;-1;1;-1;1;1])==8 %��⵽����֡ͷ
                        obj.frameBuff(1:320-k) = obj.frameBuff(k-9:310); %��֡ͷ����ı�����ǰ,320-k=310-(k-9)+1
                        obj.frameBuffPtr = 320-k; %��ʾ֡�������ж��ٸ���
                        break
                    end
                end
                if obj.frameBuffPtr==310 %û��⵽����֡ͷ
                    obj.frameBuff(1:9) = obj.frameBuff(302:310); %��δ���ı�����ǰ
                    obj.frameBuffPtr = 9;
                    obj.msgStage = 'H'; %�ٴ�Ѱ��֡ͷ
                end
            end
        end
    end

    %% ��������
    function parseEphemeris
        if obj.frameBuffPtr==1502 %������5֡
            [ephe, iono] = GPS.L1CA.epheParse(obj.frameBuff); %��������
            if ~isempty(ephe) %���������ɹ�
                if ephe(3)==ephe(4) %IODC==IODE
                    log_str = sprintf('Ephemeris is parsed at %.8fs', obj.dataIndex/obj.sampleFreq);
                    obj.log = [obj.log; string(log_str)];
                    obj.state = 2; %�ı�ͨ��״̬
                    obj.ephe = ephe; %��������
                    if ~isempty(iono)
                        obj.iono = iono; %���µ�������
                        ionoflag = 1; %���õ���������־
                    end
                else %IODC~=IODE
                    log_str = sprintf('***Ephemeris changes at %.8fs, IODC=%d, IODE=%d', ...
                                      obj.dataIndex/obj.sampleFreq, ephe(3), ephe(4));
                    obj.log = [obj.log; string(log_str)];
                end
            else %������������
                log_str = sprintf('***Ephemeris error at %.8fs', obj.dataIndex/obj.sampleFreq);
                obj.log = [obj.log; string(log_str)];
            end
            obj.frameBuff(1:2) = obj.frameBuff(1501:1502); %���������������ǰ
            obj.frameBuffPtr = 2;
        end
    end

end
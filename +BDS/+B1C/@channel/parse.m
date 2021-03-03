function parse(obj)
% ������������,ÿ1msִ��һ��
% �Ӳ��񵽽������ͬ��Ҫ300ms(�ȴ����໷�ȶ�)
% ����ͬ������Ҫ1s(100bits),��ʼѰ��֡ͷҪ��һ��ʱ��,��Ϊ�ȴ����ر߽絽��
% ����ͬ����ʹ�õ�Ƶ�������֡ͬ��
% ֡ͬ������Ҫ500ms(50bits),�ȵ���һ֡��ʼ�Ž�����������
% ֡ͬ�����ȷ���˵�Ƶ������λ,������Ҫ��ת�ز���λ,���������໷
% һ֡��������������ȷ���뷢��ʱ��
% ����18sһ��

switch obj.msgStage %I,B,W,F,H,E
    case 'I' %����
        waitPLLstable;
    case 'B' %����ͬ��
        bitSync;
	case 'W' %�ȴ����ؿ�ʼ
        waitBitStart;
    otherwise %�Ѿ���ɱ���ͬ��
        if obj.trackCnt==0 %������һ������
            if obj.msgStage~='F'
                bit = ((sum(obj.IdBuff)>0) - 0.5) * 2; %һ������,��1
            else
                bit = ((sum(obj.IpBuff)>0) - 0.5) * 2; %һ������,��1
            end
            obj.frameBuffPtr = obj.frameBuffPtr + 1; %֡����ָ���1
            obj.frameBuff(obj.frameBuffPtr) = bit; %�����ػ������
            switch obj.msgStage %���¶��ڴ���frameBuff�е�����
                case 'F' %֡ͬ��
                    frameSync;
                case 'H' %�ȴ�֡ͷ
                    waitFrameHead;
                case 'E' %��������
                    parseEphemeris;
            end
        end
end

    %% �ȴ����໷�ȶ�
    function waitPLLstable
        if obj.trackCnt==300 %��ʱ���˾���Ϊ�Ѿ��ȶ�
            obj.trackCnt = 0; %����������
            obj.msgStage = 'B'; %�������ͬ���׶�
            log_str = sprintf('Start bit synchronization at %.8fs', obj.dataIndex/obj.sampleFreq);
            obj.log = [obj.log; string(log_str)];
        end
    end

    %% ����ͬ��
    function bitSync
        if obj.I0*obj.I_Q(1)<0 %���ֵ�ƽ��ת
            index = mod(obj.trackCnt-1,10) + 1;
            obj.bitSyncTable(index) = obj.bitSyncTable(index) + 1; %ͳ�Ʊ��еĶ�Ӧλ��1
        end
        if obj.trackCnt==1000 %1s�����ͳ�Ʊ�,��ʱ��100������
            if max(obj.bitSyncTable)>10 && (sum(obj.bitSyncTable)-max(obj.bitSyncTable))<=2
                % ����ͬ���ɹ�,ȷ����ƽ��תλ��(��ƽ��ת�󶼷�����һ������)
                [~,obj.trackCnt] = max(obj.bitSyncTable); %������ֵ��Ϊͬ�������ֵ������
                obj.bitSyncTable = zeros(1,10); %����ͬ��ͳ�Ʊ�����
                obj.trackCnt = -obj.trackCnt + 1; %�������Ϊ1,�¸�����ֵ��Ϊ���ؿ�ʼ��
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
        if obj.trackCnt==0
            obj.bitSyncFlag = 1; %���ñ���ͬ����ɱ�־λ
            obj.msgStage = 'F'; %����֡ͬ���׶�
            log_str = sprintf('Start frame synchronization at %.8fs', obj.dataIndex/obj.sampleFreq);
            obj.log = [obj.log; string(log_str)];
        end
    end

    %% ֡ͬ��
    function frameSync
        % �ɼ�һ��ʱ�䵼Ƶ����,ȷ���������������е�λ��
        if obj.frameBuffPtr==50 %����50������
            R = zeros(1,1800); %50���������������в�ͬλ�õ���ؽ��
            code = [obj.codeSub, obj.codeSub(1:49)];
            x = obj.frameBuff(1:50)'; %������
            for k=1:1800
                R(k) = code(k:k+49) * x;
            end
            [Rmax, index] = max(abs(R)); %Ѱ����ؽ�������ֵ
            if Rmax==50 %������ֵ��ȷ
                %----���������໷-------------------------------------------
                if R(index)<0
                    obj.remCarrPhase = mod(obj.remCarrPhase+0.5, 1); %��ת�ز���λ
                end
                obj.subPhase = mod(index+49,1800) + 1; %ȷ����Ƶ������λ
                obj.carrDiscFlag = 1; %ʹ���������ز�������
%                 obj.set_coherentTime(4); %�ı���ɻ���ʱ��
                %----------------------------------------------------------
                obj.frameBuffPtr = mod(index+49,1800); %֡����ָ���ƶ�
                if obj.frameBuffPtr==0
                    obj.msgStage = 'E'; %������������׶�
                    log_str = sprintf('Start parse ephemeris at %.8fs', obj.dataIndex/obj.sampleFreq);
                    obj.log = [obj.log; string(log_str)];
                else
                    obj.msgStage = 'H'; %�ȴ�֡ͷ
                end
            else %������ֵ����
                obj.frameBuffPtr = 0; %֡����ָ���λ
                obj.msgStage = 'B'; %���ر���ͬ���׶�(���������֡ͬ���׶λ����ȥ)
                log_str = sprintf('***Frame synchronization failed at %.8fs', obj.dataIndex/obj.sampleFreq);
                obj.log = [obj.log; string(log_str)];
            end
        end
    end

    %% �ȴ�֡ͷ
    function waitFrameHead %��ʱ���ô���,����һ֡��
        if obj.frameBuffPtr==1800
            obj.frameBuffPtr = 0; %֡����ָ���λ
            obj.msgStage = 'E'; %������������׶�
            log_str = sprintf('Start parse ephemeris at %.8fs', obj.dataIndex/obj.sampleFreq);
            obj.log = [obj.log; string(log_str)];
        end
    end

    %% ��������
    function parseEphemeris
        if obj.frameBuffPtr==1800 %����1800������(һ֡)
            obj.frameBuffPtr = 0; %֡����ָ���λ
            [~, SOH, ephe, ~] = BDS.B1C.epheParse(obj.frameBuff);
            if ~isempty(ephe) %���������ɹ�
                if isnan(obj.tc0) %ֻ�ڿ�ʼ����һ��,��Ϊû��SOHУ��,��֪���˶�ʱ�ӵĶԲ���
                    obj.tc0 = (ephe(2)*3600 + SOH + 18) * 1000; %����α��ʱ��
                end
                if mod(ephe(3),256)==ephe(4) %IODC�ĵ�8λ==IODE
                    log_str = sprintf('Ephemeris is parsed at %.8fs', obj.dataIndex/obj.sampleFreq);
                    obj.log = [obj.log; string(log_str)];
                    obj.ephe = ephe; %��������
                    if obj.state==1
                        obj.state = 2; %�ı�ͨ��״̬
                    end
                else %IODC�ĵ�8λ~=IODE
                    log_str = sprintf('***Ephemeris changes at %.8fs, IODC=%d, IODE=%d', ...
                                       obj.dataIndex/obj.sampleFreq, ephe(3), ephe(4));
                    obj.log = [obj.log; string(log_str)];
                end
            else %������������
                log_str = sprintf('***Ephemeris error at %.8fs', obj.dataIndex/obj.sampleFreq);
                obj.log = [obj.log; string(log_str)];
            end
        end
    end

end
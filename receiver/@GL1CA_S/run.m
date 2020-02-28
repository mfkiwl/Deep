function run(obj, data)
% ���ջ����к���
% data:��������,����,�ֱ�ΪI/Q����,ԭʼ��������
% ʹ��Ƕ�׺���д,��߳���ɶ���,Ҫ��ֻ֤��obj��ȫ�ֱ���

% �����ݻ������
obj.buffI(:,obj.blockPoint) = data(1,:); %�����ݻ����ָ�������,���ü�ת��,�Զ����������
obj.buffQ(:,obj.blockPoint) = data(2,:);
obj.buffHead = obj.blockPoint * obj.blockSize; %�������ݵ�λ��
obj.blockPoint = obj.blockPoint + 1; %ָ����һ��
if obj.blockPoint>obj.blockNum
    obj.blockPoint = 1;
end
obj.tms = obj.tms + 1; %��ǰ����ʱ���1ms

% ���½��ջ�ʱ��
fs = obj.sampleFreq * (1+obj.deltaFreq); %������Ĳ���Ƶ��
obj.ta = timeCarry(obj.ta + sample2dt(obj.blockSize, fs));

% ����
if mod(obj.tms,1000)==0 %1s����һ��
    acqProcess;
end

% ����
trackProcess;

% ��λ
dtp = (obj.ta-obj.tp) * [1;1e-3;1e-6]; %��ǰ���ջ�ʱ���붨λʱ��֮��,s
if dtp>=0 %��λʱ�䵽��
    %----��ȡ���ǲ�����Ϣ
    satmeas = get_satmeas(dtp, fs);
    %----ѡ��
    sv = satmeas(~isnan(satmeas(:,1)),:); %ѡ�����ݵ���
    %----���ǵ�������
    satnav = satnavSolve(sv, obj.rp);
    dtr = satnav(13); %���ջ��Ӳ�,s
    dtv = satnav(14); %���ջ���Ƶ��,s/s
    %----���½��ջ�λ���ٶ�
    if ~isnan(satnav(1))
        obj.pos = satnav(1:3);
        obj.rp  = satnav(4:6);
        obj.vel = satnav(7:9);
        obj.vp  = satnav(10:12);
    end
    %----���ջ�ʱ������
    if obj.state==1 && ~isnan(dtv)
        
    end
    %----���ݴ洢
    obj.ns = obj.ns+1; %ָ��ǰ�洢��
    m = obj.ns;
    obj.storage.ta(m) = obj.tp * [1;1e-3;1e-6]; %��λʱ��,s
    obj.storage.state(m) = obj.state;
    obj.storage.df(m) = obj.deltaFreq;
    obj.storage.satmeas(:,:,m) = satmeas;
    obj.storage.satnav(m,:) = satnav([1,2,3,7,8,9,13,14]);
    obj.storage.pos(m,:) = obj.pos;
    obj.storage.vel(m,:) = obj.vel;
    %----���ջ�ʱ�ӳ�ʼ��
    if obj.state==0 && ~isnan(dtr)
        clock_init(dtr);
    end
    %----�����´ζ�λʱ��
    obj.tp = timeCarry(obj.tp + [0,obj.dtpos,0]);
end

    %% �������
    function acqProcess
        for k=1:obj.chN
            if obj.channels(k).state~=0 %���ͨ���Ѽ���,��������
                continue
            end
            n = obj.channels(k).acqN; %�����������
            acqResult = obj.channels(k).acq(obj.buffI((end-2*n+1):end), obj.buffQ((end-2*n+1):end));
            if ~isempty(acqResult) %����ɹ����ʼ��ͨ��
                obj.channels(k).init(acqResult, obj.tms/1000*obj.sampleFreq);
            end
        end
    end

    %% ���ٹ���
    function trackProcess
        for k=1:obj.chN
            if obj.channels(k).state==0 %���ͨ��δ����,��������
                continue
            end
            while 1
                %----�ж��Ƿ��������ĸ�������
                if mod(obj.buffHead-obj.channels(k).trackDataHead,obj.buffSize)>(obj.buffSize/2)
                    break
                end
                %----�źŴ���
                n1 = obj.channels(k).trackDataTail;
                n2 = obj.channels(k).trackDataHead;
                if n2>n1
                    obj.channels(k).track(obj.buffI(n1:n2), obj.buffQ(n1:n2), obj.deltaFreq);
                else
                    obj.channels(k).track([obj.buffI(n1:end),obj.buffI(1:n2)], ...
                                          [obj.buffQ(n1:end),obj.buffQ(1:n2)], obj.deltaFreq);
                end
                %----������������
                ionoflag = obj.channels(k).parse;
                %----��ȡ�����У������
                if ionoflag==1
                    obj.iono = obj.channels(k).iono;
                end
            end
        end
    end

    %% ��ȡ���ǲ���
    function satmeas = get_satmeas(dtp, fs)
        % dtp:��ǰ�����㵽��λ���ʱ���,s,dtp=ta-tp
        % fs:���ջ���Ƶ��У����Ĳ���Ƶ��,Hz
        % satmeas:[x,y,z,vx,vy,vz,rho,rhodot]
        lamda = 0.190293672798365; %�ز�����,m,299792458/1575.42e6
        satmeas = NaN(obj.chN,8);
        for k=1:obj.chN
            if obj.channels(k).state==2 %ֻҪ�����ϵ�ͨ�����ܲ�,���ﲻ�ù��ź�����,ѡ�Ƕ�������
                %----���㶨λ�����ӵ���ķ���ʱ��
                dn = mod(obj.buffHead-obj.channels(k).trackDataTail+1, obj.buffSize) - 1; %ǡ�ó�ǰһ��������ʱdn=-1
                dtc = dn / fs; %��ǰ�����㵽���ٵ��ʱ���,dtc=ta-tc
                dt = dtc - dtp; %��λ�㵽���ٵ��ʱ���,dtc-dtp=(ta-tc)-(ta-tp)=tp-tc=dt
                codePhase = obj.channels(k).remCodePhase + obj.channels(k).codeNco*dt; %��λ������λ
                te = [floor(obj.channels(k).tc0/1e3), mod(obj.channels(k).tc0,1e3), 0] + ...
                      [0, floor(codePhase/1023), mod(codePhase/1023,1)*1e3]; %��λ���뷢��ʱ��
                %----�����źŷ���ʱ������λ���ٶ�
                % [satmeas(k,1:6), corr] =LNAV.rsvs_emit(obj.channels(k).ephe(5:end), te, obj.rp, obj.iono, obj.pos);
                %----�����źŷ���ʱ������λ���ٶȼ��ٶ�
                [rsvsas, corr] =LNAV.rsvsas_emit(obj.channels(k).ephe(5:end), te, obj.rp, obj.iono, obj.pos);
                satmeas(k,1:6) = rsvsas(1:6);
                %----���������˶�������ز�Ƶ�ʱ仯��(��ʱ����Ʋ���,ʹ����һʱ�̵�λ�ü������,����ʸ����𲻴�)
                rs = rsvsas(1:3); %����λ��ʸ��
                vs = rsvsas(4:6); %�����ٶ�ʸ��
                as = rsvsas(7:9); %���Ǽ��ٶ�ʸ��
                rps = rs - obj.rp; %���ջ�ָ������λ��ʸ��
                R = norm(rps); %���ջ������ǵľ���
                carrAcc = -(as*rps'+vs*vs'-(vs*rps'/R)^2)/R / lamda; %�ز�Ƶ�ʱ仯��,Hz/s
                obj.channels(k).set_carrAcc(carrAcc); %���ø���ͨ���ز�Ƶ�ʱ仯��
                %----����α��α����
                tt = (obj.tp-te) * [1;1e-3;1e-6]; %�źŴ���ʱ��,s
                doppler = obj.channels(k).carrFreq/1575.42e6 + obj.deltaFreq; %��һ��,���ջ��ӿ�ʹ�����ձ�С(�������±�Ƶ)
                satmeas(k,7:8) = satmeasCorr(tt, doppler, corr);
            end
        end
    end

    %% ���ջ�ʱ�ӳ�ʼ��
    function clock_init(dtr)
        % dtr:���ǵ�������õ��Ľ��ջ��Ӳ�,s
        if abs(dtr)>0.1e-3 %�Ӳ����0.1ms,�������ջ�ʱ��
            obj.ta = obj.ta - sec2smu(dtr);
            obj.ta = timeCarry(obj.ta);
            obj.tp(1) = obj.ta(1); %�����´ζ�λʱ��
            obj.tp(2) = ceil(obj.ta(2)/obj.dtpos) * obj.dtpos;
            obj.tp = timeCarry(obj.tp);
        else %�Ӳ�С��0.1ms,��ʼ������
            obj.state = 1;
        end
    end

end
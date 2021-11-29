function satmeas = get_satmeas(obj)
% ��ȡ���ǲ���
% satmeas:[x,y,z,vx,vy,vz,rho,rhodot,phase]
% ��Ϊ����ʲôʱ�䷢������֪��,����ͨ����ȷ���㶨λ�������λ��ö�λ�����ӵ���ķ���ʱ��
% --|----------------------|-------|-------------
%   tc(trackDataTail)      tp      ta(buffHead)
%  ���ٵ�                 ��λ��  ��ǰ������
% dtp=ta-tp:��ǰ�����㵽��λ���ʱ���,ͨ��ʱ�����
% dtc=ta-tc:��ǰ�����㵽���ٵ��ʱ���,ͨ�����������
% dt=tp-tc=dtc-dtp=(ta-tc)-(ta-tp),��λ�㵽���ٵ��ʱ���,������Ƶ�ʵõ�����λ
% ����λ0~1023��Ӧ1ms

Fca = 1575.42e6; %�ز�Ƶ��
Lca = 0.190293672798365; %�ز�����,m

SMU2S = [1;1e-3;1e-6]; %[s,ms,us]��s
Cdf = 1 + obj.deltaFreq; %����Ƶ�ʵ���ʵƵ�ʵ�ϵ��
Ddf = obj.deltaFreq / Cdf; %df/(1+df)
dtp = (obj.ta-obj.tp)*SMU2S * Cdf; %��ǰ�����㵽��λ���ʱ���(���ջ���)

satmeas = NaN(obj.chN,9);
for k=1:obj.chN
    channel = obj.channels(k);
    if channel.state>=2 %ֻҪ�����ϵ�ͨ�����ܲ�,���ﲻ�ù��ź�����,ѡ�Ƕ�������
        %----���㶨λ�����ӵ���ķ���ʱ��
        dn = mod(obj.buffHead-channel.trackDataTail+1, obj.buffSize) - 1; %ǡ�ó�ǰһ��������ʱdn=-1
        dtc = dn / obj.sampleFreq; %��ǰ�����㵽���ٵ��ʱ���(���ջ���)
        dt = dtc - dtp; %��λ�㵽���ٵ��ʱ���(���ջ���)
        codePhase = channel.remCodePhase + channel.codeNco*dt; %��λ������λ
        te = [floor(channel.tc0/1e3), mod(channel.tc0,1e3), 0] + ...
             [0, floor(codePhase/1023), mod(codePhase/1023,1)*1e3]; %��λ���뷢��ʱ��
        %----�����źŷ���ʱ������λ���ٶ�
        % [satmeas(k,1:6), corr] = LNAV.rsvs_emit(channel.ephe(5:end), te, obj.rp, obj.vp, obj.iono, obj.pos);
        %----�����źŷ���ʱ������λ���ٶȼ��ٶ�
        [rsvsas, corr] = LNAV.rsvsas_emit(channel.ephe(5:end), te, obj.rp, obj.vp, obj.iono, obj.pos);
        satmeas(k,1:6) = rsvsas(1:6);
        %----���������˶�������ز�Ƶ�ʱ仯��(��ʱ����Ʋ���,ʹ����һʱ�̵�λ�ü������,����ʸ����𲻴�)
        rhodotdot = rhodotdot_cal(rsvsas, obj.rp, obj.vp, obj.geogInfo);
        channel.carrAccS = -rhodotdot/Lca / Cdf; %���ø���ͨ���ز�Ƶ�ʱ仯��,Hz/s
        %----����α��α����
        tt = (obj.tp-te) * SMU2S; %�źŴ���ʱ��,s
        carrAcc = channel.carrAccS + channel.carrAccR; %�ز����ٶ�(�ڴ���ٶ�ʱ�迼�Ƕ�λ������ٵ�ʱ�����ڵĶ����ձ仯)
        dCarrFreq = carrAcc * (dt-0.5e-3); %���ٵ����ز�Ƶ��ʵ�������¸�1ms����ʱ���м�ʱ�̵��ز�Ƶ��
        doppler = (channel.carrFreq+dCarrFreq)*Cdf/Fca + obj.deltaFreq; %��һ��,���ջ��ӿ�ʹ�����ձ�С(�������±�Ƶ)
        satmeas(k,7:8) = satmeasCorr(tt, doppler, corr);
        %----�����ز���λ(������ת���ɾ���ʱֱ�ӳ��Ա�Ʋ���)
        clockError = obj.clockError + dt*Ddf; %����λ���ۻ��˶����Ӳ�
        carrPhase = channel.carrCirc - channel.remCarrPhase - channel.carrNco*dt; %��λ����ز���λ(�ۻ���Ƶ��)
        carrPhase = carrPhaseCorr(carrPhase, corr, Fca); %�ز���λУ��
        carrPhase = carrPhase - clockError*Fca; %�������ջ��Ӳ�
        dL = satmeas(k,7) - carrPhase*Lca; %�ز���λ��Ӧ�ľ�����α��֮��
        if abs(dL)>300 %��������300m,����е���,���ز���λ��α��ƥ��
            dcarrCirc = round(dL/Lca); %�ز���λ����������
            channel.carrCirc = channel.carrCirc + dcarrCirc; %���ز���λ���ܼ���
            carrPhase = carrPhase + dcarrCirc; %���ز���λ
        end
        satmeas(k,9) = carrPhase; %(���޽��ջ��ӵ�ʱ��,�ز���λ��Ư)
    end
end

end
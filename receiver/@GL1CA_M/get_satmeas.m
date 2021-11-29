function [satpv, satmeas] = get_satmeas(obj)
% ��ȡ���ǲ���
% satpv:[x,y,z,vx,vy,vz]
% satmeas:[rho,rhodot,phase],Ԫ������,ÿ��Ԫ��Ϊһ������

Fca = 1575.42e6; %�ز�Ƶ��
Lca = 0.190293672798365; %�ز�����,m

SMU2S = [1;1e-3;1e-6]; %[s,ms,us]��s
Cdf = 1 + obj.deltaFreq; %����Ƶ�ʵ���ʵƵ�ʵ�ϵ��
Ddf = obj.deltaFreq / Cdf; %df/(1+df)
dtp = (obj.ta-obj.tp)*SMU2S * Cdf; %��ǰ�����㵽��λ���ʱ���(���ջ���)

satpv = NaN(obj.chN,6);
corr = cell(obj.chN,1);
carrAccS = NaN(obj.chN,1);
satmeas = cell(1,obj.anN);
for m=1:obj.anN
    satmeas{m} = NaN(obj.chN,3);
    for k=1:obj.chN
        channel = obj.channels(k,m);
        if channel.state>=2 %ֻҪ�����ϵ�ͨ�����ܲ�,���ﲻ�ù��ź�����,ѡ�Ƕ�������
            %----���㶨λ�����ӵ���ķ���ʱ��
            dn = mod(obj.buffHead-channel.trackDataTail+1, obj.buffSize) - 1; %ǡ�ó�ǰһ��������ʱdn=-1
            dtc = dn / obj.sampleFreq; %��ǰ�����㵽���ٵ��ʱ���(���ջ���)
            dt = dtc - dtp; %��λ�㵽���ٵ��ʱ���(���ջ���)
            codePhase = channel.remCodePhase + channel.codeNco*dt; %��λ������λ
            te = [floor(channel.tc0/1e3), mod(channel.tc0,1e3), 0] + ...
                 [0, floor(codePhase/1023), mod(codePhase/1023,1)*1e3]; %��λ���뷢��ʱ��
            %----�����źŷ���ʱ������λ���ٶȼ��ٶ�,�����˶�������ز�Ƶ�ʱ仯��(���ظ���)
            if isnan(satpv(k,1))
                [rsvsas, corr{k}] = LNAV.rsvsas_emit(channel.ephe(5:end), te, obj.rp, obj.vp, obj.iono, obj.pos);
                satpv(k,:) = rsvsas(1:6);
                rhodotdot = rhodotdot_cal(rsvsas, obj.rp, obj.vp, obj.geogInfo);
                carrAccS(k) = -rhodotdot/Lca / Cdf;
            end
            channel.carrAccS = carrAccS(k); %���ø���ͨ���ز�Ƶ�ʱ仯��,Hz/s
            %----����α��α����
            tt = (obj.tp-te) * SMU2S; %�źŴ���ʱ��,s
            carrAcc = channel.carrAccS + channel.carrAccR; %�ز����ٶ�(�ڴ���ٶ�ʱ�迼�Ƕ�λ������ٵ�ʱ�����ڵĶ����ձ仯)
            dCarrFreq = carrAcc * (dt-0.5e-3); %���ٵ����ز�Ƶ��ʵ�������¸�1ms����ʱ���м�ʱ�̵��ز�Ƶ��
            doppler = (channel.carrFreq+dCarrFreq)*Cdf/Fca + obj.deltaFreq; %��һ��,���ջ��ӿ�ʹ�����ձ�С(�������±�Ƶ)
            satmeas{m}(k,1:2) = satmeasCorr(tt, doppler, corr{k});
            %----�����ز���λ(������ת���ɾ���ʱֱ�ӳ��Ա�Ʋ���)
            clockError = obj.clockError + dt*Ddf; %����λ���ۻ��˶����Ӳ�
            carrPhase = channel.carrCirc - channel.remCarrPhase - channel.carrNco*dt; %��λ����ز���λ(�ۻ���Ƶ��)
            carrPhase = carrPhaseCorr(carrPhase, corr{k}, Fca); %�ز���λУ��
            carrPhase = carrPhase - clockError*Fca; %�������ջ��Ӳ�
            dL = satmeas{m}(k,1) - carrPhase*Lca; %�ز���λ��Ӧ�ľ�����α��֮��
            if abs(dL)>300 %��������300m,����е���,���ز���λ��α��ƥ��
                dcarrCirc = round(dL/Lca); %�ز���λ����������
                channel.carrCirc = channel.carrCirc + dcarrCirc; %���ز���λ���ܼ���
                carrPhase = carrPhase + dcarrCirc; %���ز���λ
            end
            satmeas{m}(k,3) = carrPhase; %(���޽��ջ��ӵ�ʱ��,�ز���λ��Ư)
        end
    end
end

end
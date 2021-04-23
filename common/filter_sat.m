classdef filter_sat < handle
% ���ǵ����˲���
    
    properties
        pos        %λ��,γ����
        vel        %�ٶ�,����ϵ
        rp         %λ��,ecef
        vp         %�ٶ�,ecef
        acc        %���ٶ�
        dtr        %�Ӳ�,s
        dtv        %��Ƶ��,s/s
        geogInfo   %������Ϣ
        T          %��������
        P          %P��
        Q          %Q��
    end
    
    methods
        %% ���캯��
        function obj = filter_sat(para)
            c = 3e8; %���ٽ���ֵ
            obj.pos = para.p0;
            obj.vel = para.v0;
            Cen = dcmecef2ned(obj.pos(1), obj.pos(2));
            obj.rp = lla2ecef(obj.pos);
            obj.vp = obj.vel*Cen;
            obj.acc = [0,0,0];
            obj.dtr = 0;
            obj.dtv = 0;
            obj.geogInfo = geogInfo_cal(obj.pos, obj.vel);
            obj.T = para.dt;
            obj.P = diag([para.P0_pos *[1,1,1], ...
                          para.P0_vel *[1,1,1], ...
                          para.P0_acc *[1,1,1], ...
                          para.P0_dtr *c, ...
                          para.P0_dtv *c ...
                         ])^2; %para��P0���Ǳ�׼��
            obj.Q = diag([para.Q_pos *[1,1,1], ...
                          para.Q_vel *[1,1,1], ...
                          para.Q_acc *[1,1,1], ...
                          para.Q_dtr *c, ...
                          para.Q_dtv *c ...
                         ])^2 * obj.T^2; %para��Q���Ǳ�׼��
        end
        
        %% ���к���
        function [innP, innV] = run(obj, sv, indexP, indexV)
            % indexP,indexV���������߼�ֵ
            n = length(indexP);
            innP = NaN(1,n); %α����Ϣ(α���Z)
            innV = NaN(1,n); %α������Ϣ(α���ʵ�Z)
            %----��ȡ���ǲ���(ÿ��һ������)
            rs = sv(:,1:3);     %����ecefλ��
            vs = sv(:,4:6);     %����ecef�ٶ�
            rho = sv(:,7);      %������α��
            rhodot = sv(:,8);   %������α����
            R_rho = sv(:,9);    %α����������
            R_rhodot= sv(:,10); %α������������
            %----����̵ı�����
            r2d = 180/pi;
            c = 299792458;
            dt = obj.T;
            v0 = obj.vel;
            lat = obj.pos(1); %deg
            lon = obj.pos(2); %deg
            h = obj.pos(3);
            %----�ٶȽ���
            v = v0 + obj.acc*dt;
            %----λ�ý���
            dp = (v0+v)/2*dt; %λ������
            lat = lat + dp(1)*obj.geogInfo.dlatdn*r2d; %deg
            lon = lon + dp(2)*obj.geogInfo.dlonde*r2d; %deg
            h = h - dp(3);
            %----�����Ӳ�
            obj.dtr = obj.dtr + obj.dtv*dt;
            %----״̬����
            A = zeros(11);
            A(1,4) = 1;
            A(2,5) = 1;
            A(3,6) = 1;
            A(4,7) = 1;
            A(5,8) = 1;
            A(6,9) = 1;
            A(10,11) = 1;
            Phi = eye(11) + A*dt + (A*dt)^2/2;
            %----״̬����
            P1 = Phi*obj.P*Phi' + obj.Q;
            X = zeros(11,1);
            %----����ά��
            n1 = sum(indexP); %α���������
            n2 = sum(indexV); %α�����������
            %----�������
            if n1>0 %����������
                %----���ݵ�ǰ�����������������Ծ��������ٶ�
                [rho0, rhodot0, rspu, Cen] = rho_rhodot_cal_geog(rs, vs, [lat,lon,h], v);
                %----�������ⷽ��,������,��������������
                S = -sum(rspu.*vs,2);
                cm = 1 + S/c; %����������
                En = rspu*Cen'; %����Ϊ����ϵ������ָ����ջ��ĵ�λʸ��
                H = zeros(n1+n2,11);
                H(1:n1,1:3) = En(indexP,:);
                H(1:n1,10) = -ones(n1,1);
                H((n1+1):end,4:6) = En(indexV,:);
                H((n1+1):end,11) = -cm(indexV);
                %-------------------�����Ӳ���Ƶ��-------------------------%
                rho = rho - obj.dtr*c;
                rhodot = rhodot - obj.dtv*c;
                %---------------------------------------------------------%
                Z = [rho0(indexP) - rho(indexP); ...
                     rhodot0(indexV) - rhodot(indexV).*cm(indexV)]; %����ֵ������ֵ
                R = diag([R_rho(indexP);R_rhodot(indexV)]);
                %----�����Ϣ
                innP(indexP) = Z(1:n1);
                innV(indexV) = Z(n1+1:n1+n2);
                %----�˲�
                K = P1*H' / (H*P1*H'+R);
                X = K*Z;
                %----Huber��Ȩ(�в�У��)
%                 P1 = (P1+P1')/2; %��Ҫ��֤PΪ�Գ���,���򿪷�ʱ����ָ���
%                 P_sqrt = sqrtm(P1); %P��ƽ����
%                 R_diag = diag(R); %R�ĶԽ���Ԫ��
%                 R_sqrt_diag = sqrt(R_diag); %R�ĶԽ���Ԫ�ص�ƽ����
%                 gamma = 1.3; %Huberϵ��
%                 for k=1:2 %������
%                     Psi_P_diag = HuberWeight(P_sqrt\X, gamma); %״̬����Ȩֵ
%                     Psi_R_diag = HuberWeight((Z-H*X)./R_sqrt_diag, gamma); %��������Ȩֵ
%                     P0 = P_sqrt * diag(1./Psi_P_diag) * P_sqrt; %��Ȩ���P��
%                     R0 = diag(R_diag./Psi_R_diag); %��Ȩ���R��
%                     K = P0*H' / (H*P0*H'+R0);
%                     X = K*Z;
%                     if any(imag(X))
%                         error('Complex number in the filter!')
%                     end
%                 end
%                 P1 = P0;
                %----Huber��Ȩ(��)
                R_diag = diag(R); %R�ĶԽ���Ԫ��
                R_sqrt_diag = sqrt(R_diag); %R�ĶԽ���Ԫ�ص�ƽ����
                gamma = 1.3; %Huberϵ��
                for k=1:2 %������
                    Psi_R_diag = HuberWeight((Z-H*X)./R_sqrt_diag, gamma); %��������Ȩֵ
                    R0 = diag(R_diag./Psi_R_diag); %��Ȩ���R��
                    K = P1*H' / (H*P1*H'+R0);
                    X = K*Z;
                end
                %----����P��
                P1 = (eye(11)-K*H)*P1;
            end
            %----����P��
            obj.P = (P1+P1')/2;
            %----��������
            lat = lat - X(1)*obj.geogInfo.dlatdn*r2d; %deg
            lon = lon - X(2)*obj.geogInfo.dlonde*r2d; %deg
            h = h + X(3);
            v = v - X(4:6)';
            %----���µ�������
            obj.pos = [lat,lon,h];
            obj.vel = v;
            obj.rp = lla2ecef(obj.pos);
            Cen = dcmecef2ned(lat, lon);
            obj.vp = v*Cen;
            obj.acc = obj.acc - X(7:9)';
            obj.dtr = obj.dtr + X(10)/c; %s
            obj.dtv = obj.dtv + X(11)/c; %s/s
            obj.geogInfo = geogInfo_cal(obj.pos, obj.vel); %���µ�����Ϣ
        end
        
    end %end methods
    
end %end classdef
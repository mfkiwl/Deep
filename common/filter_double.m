classdef filter_double < INS_GRC
% 双天线导航滤波器,位置速度都是惯导的
% 继承于惯导类
    
    properties
        dtr        %钟差估计值,s
        dtv        %钟频差估计值,s/s
        bias       %零偏估计值,[gyro,acc],[rad/s,m/s^2]
        P          %P阵
        Q          %Q阵
        motion     %运动状态检测
        Rwb        %陀螺仪输出噪声方差
        wbDelay    %延迟的角速度输出
        arm        %杆臂矢量,体系下IMU指向天线
        wdotCal    %角加速度计算模块
        wdot       %角加速度值,rad/s^2
        windupFlag %发条效应校正标志
        base       %基线矢量
    end
    
    methods
        %% 构造函数
        function obj = filter_double(para)
            %----惯导初始化------------------
            para_ins.p0 = para.p0;
            para_ins.v0 = para.v0;
            para_ins.a0 = para.a0;
            para_ins.dt = para.dt;
            obj@INS_GRC(para_ins);
            %--------------------------------
            d2r = pi/180;
            g0 = 9.8; %重力加速度近似值
            c = 3e8; %光速近似值
            obj.dtr = 0;
            obj.dtv = 0;
            obj.bias = [0,0,0,0,0,0];
            obj.T = para.dt;
            obj.P = diag([para.P0_att  *[1,1,1]*d2r, ...
                          para.P0_vel  *[1,1,1], ...
                          para.P0_pos  *[1,1,1], ...
                          para.P0_dtr  *c, ...
                          para.P0_dtv  *c, ...
                          para.P0_gyro *[1,1,1]*d2r, ...
                          para.P0_acc  *[1,1,1]*g0 ...
                         ])^2; %para的P0都是标准差
            obj.Q = diag([para.Q_gyro *[1,1,1]*d2r, ...
                          para.Q_acc  *[1,1,1]*g0, ...
                          para.Q_acc  *[1,1,1]*g0*(obj.T*1), ...
                          para.Q_dtv  *c*(obj.T*1), ...
                          para.Q_dtv  *c, ...
                          para.Q_dg   *[1,1,1]*d2r, ...
                          para.Q_da   *[1,1,1]*g0 ...
                         ])^2 * obj.T^2; %para的Q都是标准差
            obj.motion = motionDetector_gyro_vel(para.gyro0, obj.T, 0.8); %0.6
            obj.Rwb = (para.sigma_gyro*d2r)^2;
            obj.wbDelay = delayN(20, 3);
            obj.arm = para.arm;
            obj.wdotCal = omegadot_cal(obj.T, 3);
            obj.wdot = [0,0,0];
            obj.windupFlag = para.windupFlag;
            obj.base = para.base;
        end
        
        %% 运行函数
        function run(obj, imu, sv, indexP, indexV, indexA)
            % indexP,indexV,indexA索引都是逻辑值
            % flag=0,只做惯导解算和时间更新;flag=1,做量测更新
            if nargin==2
                flag = 0;
            else
                flag = 1;
            end
            r2d = 180/pi;
            c = 299792458;
            dt = obj.T;
            wbo = imu(1:3); %原始的角速度
            %----运动状态检测(使用角速度和速度)
            obj.motion.run(wbo*r2d, obj.vel); %deg/s
            %----计算角加速度
            obj.wdot = obj.wdotCal.run(wbo); %rad/s
            %----角速度延迟
            wbd = obj.wbDelay.push(wbo);
            wbd = wbd - obj.bias(1:3); %减当前零偏
            %----零偏补偿
            imu = imu - obj.bias;
            wb1 = imu(1:3);
            fb1 = imu(4:6);
%             wb = (wb1+obj.imu0(1:3))/2;
%             fb = (fb1+obj.imu0(4:6))/2;
            %----惯导解算
            obj.solve(imu, 1);
            %----更新钟差
            obj.dtr = obj.dtr + obj.dtv*dt;
            %----状态方程
            Cnb = quat2dcm(obj.quat);
            Cbn = Cnb';
            fn = fb1*Cnb;
            winn = obj.geogInfo.wien + obj.geogInfo.wenn;
%             winn2 = winn + obj.geogInfo.wien;
            A = zeros(17);
%             A(1:3,1:3) = antisym(winn);
            A(1:3,12:14) = -Cbn;
            A(4:6,1:3) = antisym(fn);
%             A(4:6,4:6) = antisym(winn2);
            A(4:6,15:17) = Cbn;
            A(7,4) = 1;
            A(8,5) = 1;
            A(9,6) = 1;
            A(10,11) = 1;
            Phi = eye(17) + A*dt + (A*dt)^2/2;
            %----状态更新
            P1 = Phi*obj.P*Phi' + obj.Q;
            X = zeros(17,1);
            %----量测更新
            measureFlag = 0;
            if flag==1 && sum(indexP)>0 && obj.accJump.state==0 %有卫星量测并且没有加速度突变
                measureFlag = 1;
                %----量测维数
                n1 = sum(indexP); %伪距量测个数
                n2 = sum(indexV); %伪距率量测个数
                n3 = sum(indexA); %载波相位量测个数
                %----提取卫星测量(每行一颗卫星)
                rs = sv(:,1:3);     %卫星ecef位置
                vs = sv(:,4:6);     %卫星ecef速度
                rho = sv(:,7);      %测量的伪距
                rhodot = sv(:,8);   %测量的伪距率
                phase = sv(:,11);   %测量的载波相位,m
                R_rho = sv(:,9);    %伪距噪声方差
                R_rhodot= sv(:,10); %伪距率噪声方差
                R_phase = sv(:,12);  %载波相位噪声方差,m^2
                %----根据当前导航结果计算理论相对距离和相对速度
                [rho0, rhodot0, rspu, Cen] = rho_rhodot_cal_geog(rs, vs, obj.pos, obj.vel);
                %----地理系下视线矢量
                S = -sum(rspu.*vs,2);
                cm = 1 + S/c; %光速修正项
                En = rspu*Cen'; %各行为地理系下卫星指向接收机的单位矢量
                %----修正钟差钟频差
                rho = rho - obj.dtr*c;
                rhodot = rhodot - obj.dtv*c - obj.windupFlag*wb1(3)*0.030286178664972; %299792458/1575.42e6/(2*pi)
                %----对测量的伪距伪距率进行杆臂修正
                Eb = En*Cbn; %各行为本体系下卫星指向接收机的单位矢量
                rho = rho - Eb*obj.arm'; %如果天线放在惯导位置应该测得的伪距
                vab = cross(wb1,obj.arm); %杆臂引起的速度
                rhodot = rhodot - Eb*vab'; %如果天线放在惯导位置应该测得的伪距率
                %----伪距量测部分
                H1 = zeros(n1,17);
                H1(:,7:9) = En(indexP,:);
                H1(:,10) = -1;
                Z1 = rho0(indexP) - rho(indexP);
                R1 = diag(R_rho(indexP));
                %----伪距率量测部分
                H2 = []; Z2 = []; R2 = [];
                if n2>0
                    H2 = zeros(n2,17); %伪距率量测方程
                    H2(:,4:6) = En(indexV,:);
                    H2(:,11) = -cm(indexV);
                    Z2 = rhodot0(indexV) - rhodot(indexV).*cm(indexV);
                    if obj.motion.state==0 %运动时将伪距率量测噪声方差放大
                        R2 = diag(R_rhodot(indexV));
                    else
                        R2 = diag(R_rhodot(indexV)*1);
                    end
                end
                %----载波相位量测部分
                H3 = []; Z3 = []; R3 = [];
                if n3>2
                    H3 = zeros(n3,17); %载波相位量测方程
                    rbn = obj.base*Cnb; %地理系基线矢量
                    E = En(indexA,:);
                    H3(:,1:3) = E*antisym(rbn);
                    Z3 = E*rbn' - phase(indexA);
                    if obj.motion.state==0 %运动时将载波相位量测噪声方差放大
                        R3 = diag(R_phase(indexA));
                    else
                        R3 = diag(R_phase(indexA)*1);
                    end
                    % 星间差分
                    Js = [-ones(n3-1,1), eye(n3-1)];
                    H3 = Js*H3;
                    Z3 = Js*Z3;
                    R3 = Js*R3*Js';
                    % 视线矢量水平投影变换
                    D = Js*E;
                    Jh = [-D(2:end,3), eye(n3-2)*D(1,3)];
                    H3 = Jh*H3;
                    Z3 = Jh*Z3;
                    R3 = Jh*R3*Jh';
                end
                %----角速度量测部分
                H4 = []; Z4 = []; R4 = [];
                if obj.motion.state==0 %静止时加入角速度量测
                    H4 = zeros(3,17);
                    H4(:,12:14) = eye(3);
                    Z4 = (wbd-winn*Cbn)';
                    R4 = diag([1;1;1]*obj.Rwb);
                end
                %----构造量测矩阵,量测量,量测噪声方差阵
                H = [H1; H2; H3; H4];
                Z = [Z1; Z2; Z3; Z4];
                R = blkdiag(R1, R2, R3, R4);
                %----滤波
                K = P1*H' / (H*P1*H'+R);
                X = K*Z;
                %----Huber加权(简化)(会影响P阵收敛值)
%                 R_diag = diag(R); %R的对角线元素
%                 R_sqrt_diag = sqrt(R_diag); %R的对角线元素的平方根
%                 gamma = 1.345; %Huber系数
%                 for k=1:2 %算两次
%                     Psi_R_diag = HuberWeight((Z-H*X)./R_sqrt_diag, gamma); %量测量的权值
%                     R0 = diag(R_diag./Psi_R_diag); %加权后的R阵
%                     K = P1*H' / (H*P1*H'+R0);
%                     X = K*Z;
%                 end
                %----计算P阵
                P1 = (eye(17)-K*H)*P1;
            elseif obj.motion.state==0 %静止时加入角速度量测
                measureFlag = 2;
                H = zeros(3,17);
                H(:,12:14) = eye(3);
                Z = (wbd-winn*Cbn)';
                R = diag([1;1;1]*obj.Rwb);
                K = P1*H' / (H*P1*H'+R);
                X = K*Z;
                P1 = (eye(17)-K*H)*P1;
            end
            %----状态约束
            if measureFlag~=0
                Y = [];
                if obj.motion.state==0 %静止时不估水平加速度计零偏
                    Ysub = zeros(2,17);
                    Ysub(1,15) = 1;
                    Ysub(2,16) = 1;
                    Y = [Y; Ysub];
                end
                if ~isempty(Y)
                    X = X - P1*Y'/(Y*P1*Y')*Y*X;
                end
            end
            %----更新P阵
            obj.P = (P1+P1')/2;
            %----导航修正
            X = X'; %转成行向量
            obj.correct(X(1:9));
            obj.dtr = obj.dtr + X(10)/c; %s
            obj.dtv = obj.dtv + X(11)/c; %s/s
            obj.bias(1:3) = obj.bias(1:3) + X(12:14); %rad/s
            obj.bias(4:6) = obj.bias(4:6) + X(15:17); %m/s^2
        end
        
    end %end methods
    
end %end classdef
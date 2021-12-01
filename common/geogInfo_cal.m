function geogInfo = geogInfo_cal(lla, vel)
% ����γ���ߺ͵���ϵ�ٶȼ��������Ϣ

lat = lla(1); %deg
lon = lla(2); %deg
h = lla(3);
sin_lat = sind(lat);
cos_lat = cosd(lat);
[Rm, Rn] = earthCurveRadius(lat);
dlatdn = 1/(Rm+h);
dlonde = 1/((Rn+h)*cos_lat); %���ȶԶ���λ�Ƶĵ���
Cen = dcmecef2ned(lat, lon);
wien = [cos_lat, 0, -sin_lat] * 7.292115e-5;
wenn = [vel(2)*dlonde*cos_lat, -vel(1)*dlatdn, -vel(2)*dlonde*sin_lat];
wiee = [0 ,0, 7.292115e-5];
wene = wenn*Cen;
g = gravitywgs84(h, lat);

geogInfo.Rm = Rm; %����Ȧ�뾶(�����߶�)
geogInfo.Rn = Rn; %î��Ȧ�뾶(�����߶�)
geogInfo.dlatdn = dlatdn; %γ�ȶԱ���λ�Ƶĵ���(���߶�)
geogInfo.dlonde = dlonde; %���ȶԶ���λ�Ƶĵ���(���߶�)
geogInfo.Cn2g = diag([dlatdn/pi*180, dlonde/pi*180, -1]); %����ϵλ��ת�ɾ�γ�ȵľ���
geogInfo.wien = wien;
geogInfo.wenn = wenn;
geogInfo.wiee = wiee;
geogInfo.wene = wene;
geogInfo.g = g; %�������ٶ�,m/s^2

end
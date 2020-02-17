function dcm = dcmecef2ned(lat, lon)
% ecefϵ������ϵ������任��
% lat,lon��λ:deg

sinlat = sind(lat);
coslat = cosd(lat);
sinlon = sind(lon);
coslon = cosd(lon);

dcm = [-sinlat*coslon, -sinlat*sinlon,  coslat;
              -sinlon,         coslon,       0;
       -coslat*coslon, -coslat*sinlon, -sinlat];

end
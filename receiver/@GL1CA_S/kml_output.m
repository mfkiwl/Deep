function kml_output(obj)
% ���kml�ļ�

kmlwriteline('~temp\traj.kml', obj.storage.pos(:,1),obj.storage.pos(:,2), ...
             'Color','r', 'Width',2);

end
%%%%Check the total of images will be used&&&&
clear
clc
% Load LOS data
files=dir('*.txt');                     %Create data list using .txt format
for i=1:103
    nama_file=files(i).name;            %name file identification
    fid=fopen(nama_file,'r');           %open file
    formatSpec='%f %f %f';
    data=fscanf(fid,formatSpec,[3 Inf]);        %read file data
    data=data';
    f1=find(~isnan(data(:,3)));                    %filter data line more than 0
    data=data(f1,:);                    %Collect data more than 0
    l_f=length(nama_file);
    if l_f == 5
    eval(['data_' num2str(nama_file(1)) '=data']);
    else
    eval(['data_' num2str(nama_file(1:2)) '=data']);
    end
    z=data(:,3);
    los(:,i)=z;
end
%Load date
thisfile = files(104).name ;
eval(['load ' files(104).name]);

%Constant Parameter
M = ones(103,2);
doy = [date.*M(:,1) M(:,2)];
for i = 1:length(los)
    b(i,:) = ((doy'*doy)^-1)*doy'*los(i,:)';
end

%Prediction
H = doy*((doy'*doy)^-1)*doy';
for i = 1:length(los)
    y(i,:) = H*los(i,:)';
end

%Prediction - LOS
losmin = (los-y);
lospre = (losmin).^2;
sumlospre = sum(lospre,2);
sqrtsumlospre = sqrt(sumlospre);
%Degree of Freedome
dof = length(H)-2;

%Time
avedate = mean(date,1);
transdate = date';
for i = 1:length(H)
    time = (transdate(1,i)-avedate);
end
sumtime = sum((time.^2),2);

%Uncertainty
uncertaintytime = sqrt(sumlospre/(dof*sumtime));

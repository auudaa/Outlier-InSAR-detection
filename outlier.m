%%%%Check the total of images SAR and standart deviation&&&&
%Raudlah
clear
clc
% Load LOS data
files=dir('*.txt');                     %Create list data using .txt format
for i=1:103
    nama_file=files(i).name;            %name file identification
    fid=fopen(nama_file,'r');           %open file
    formatSpec='%f %f %f';
    data=fscanf(fid,formatSpec,[3 Inf]);        %read file data
    data=data';
    f1=find(~isnan(data(:,3)));                    %filter line data more than 0
    data=data(f1,:);                    %Take data more than 0
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
dof = length(H);

%Uncertainty (time)
uncertaintytime = sqrt(sumlospre/(dof-2));

%average of los
avelos=mean(los,2);

%outlier per time
for i = 1:length(los);
lefttime(i,:) = avelos(i,:)-(2*uncertaintytime(i,:)); %sigma
righttime(i,:) = avelos(i,:)+(2*uncertaintytime(i,:)); %sigma
end
outliertime = lefttime>los | righttime<los;

%outlier per space
sumoutlier = sum(outliertime,1);
averagesumoutlier = mean(sumoutlier,2);
percentoutlier = sumoutlier/length(los)*100;

for i=1:length(H);
    minoutlier(1,i) = ((sumoutlier(1,i)-averagesumoutlier).^2);
end
summinoutlier=sum(minoutlier,2);
uncertaintyspace = sqrt(summinoutlier/(108-2)); %The total of images
rightspace = averagesumoutlier+(2*uncertaintyspace); %sigma
outlierspace = rightspace<sumoutlier; %Selection outlier or not
totalspaceout = outlierspace.*sumoutlier; %The total of outlier per images

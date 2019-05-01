function [timeapprox, EXPLAINED]=pcaCalc(x_raw)
%% PCA Calculation
%  Daniel Elbich
%  5/8/15

%  This program conducts PCA anlaysis on timeseries from a dataset,
%  deriving a principalcomponent and transforms the primary component back
%  into the time domainfor connectivity analyses.

if isempty(x_raw)==1
    h=msgbox('No data available.');
    return;
end

ny=size(x_raw,2);
nt=size(x_raw,1);

y=x_raw;

for i=1:ny
    ymean(i)=mean(y(:,i));
end

for i=1:ny
    for j=1:nt
        y(j,i)=y(j,i)-ymean(i);
    end
end

[COEFF, SCORE, LATENT, TSQUARED, EXPLAINED]=pca(x_raw);

qq=0;

for i=1:ny
    q=COEFF(i,1)^2;
    qq=qq+(q*ymean(i));
end


for i=1:nt
    x(i)=qq;
    
    for j=1:ny
        x(i)=x(i)+(COEFF(j,1)*y(i,j));
    end
    
end

timeapprox=x';
end

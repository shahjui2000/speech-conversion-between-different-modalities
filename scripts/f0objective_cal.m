clc; clear all; close all;

load_path_mcep = ['../Results/mask/mcc'];
load_path_VU = ['../Results/mask/VUV'];
load_path_F0 = ['../Results/mask/f0'];
save_path_F0 =[ '../Results/converted_f0/'];
save_data = ['../Results/'];
dim=40;

filelist1=dir(['../dataset/features/US_102/Normal/mcc/*.mcc']);
x=[];y=[];cx=[];mcd=[];C=[];F=[];Ft=[];ix=[];rs=[]; cr=[];R=[]; CR=[];
for index=1:length(filelist1)
    fprintf('Processing %s\n',filelist1(index).name); 
    fid=fopen(['../dataset/features/US_102/Normal/mcc/',filelist1(index).name]);
    x=fread(fid,Inf,'float');
    x=reshape(x,dim,length(x)/dim);
                   
    
                  
    load([load_path_mcep,'Test_Batch_',num2str(index-1),'.mat']);
    y=foo';
    
    clear foo;
    [min_distance,d,g,path] = dtw_E(y,x);
    
    load([load_path_VU,'Test_Batch_',num2str(index-1),'.mat']);
    a=foo;
    a(a>=0.5) = 1;
    a(a<0.5) = 0;
    clear foo;
    a=a';

    fid3=fopen(['../dataset/features/Normal/f0/',filelist1(index).name(1:end-3),'f0']);
    f0=fread(fid3,Inf,'float');
    
    load([load_path_F0,'Test_Batch_',num2str(index-1),'.mat']);
    fp=foo;
    coeff=ones(1,3)/3;
    fp=filter(coeff,1,fp);
    ft=fp.*a';
    
    
    ft(ft==0)=-1e+10;
    
    [rs,cr]=objf0(ft(path(:,1)),f0(path(:,2)));
    R(index)=rs;
    CR(index)=cr;
    ft=double(ft);
    save([save_path_F0,filelist1(index).name(1:end-3),'f0'],'ft','-ascii');
    %mcd(index)=cal_mcd(cx(1:25,:),y);
    fclose('all'); 
end
 mR=mean(R);
 sdr=std(R);
 mC=mean(CR);
 sC=std(CR);
 fid4=fopen([save_data,'F0_objective.txt'],'a');
 
 fmt='US_102 RMSE: %3.2f (std) %3.2f VUD: %2.3f (std) %2.3f \n';
 fprintf(fid4,fmt,SRC{sr},mR,sdr, mC, sC);                
 fclose(fid4);

 

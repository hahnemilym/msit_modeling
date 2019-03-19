%% Wrapper Script for DARPA MRI ECR State-Space
% Modeling: RT(k) ~ w0 + w1 * Interference + x(k)
clear all;
close all;

%% Import state space code. 
%addpath('COMPASS_StateSpaceToolbox');

%err_subjets = {'hc001','hc007','hc013','hc022',...
%                'hc024','hc029','hc030','hc035',...
%                 'pp005','pp014'}

%subjects = {'hc002','hc003','hc004','hc005','hc006','hc008',...
%    'hc009','hc010','hc011','hc012','hc014','hc015','hc016',...
%    'hc017','hc018','hc019','hc020','hc021','hc023','hc025',...
%    'hc026','hc028','hc031','hc032','hc033','hc034','hc036',...
%    'hc037','hc038','hc042','hc044','hc045','pp001','pp002',...
%    'pp003','pp004','pp006','pp007','pp008','pp009','pp010',...
%    'pp011','pp012','pp013','pp015','pp016'};

subjects = {'pp014'}

%% ONLY RUN ONE SUBJECT
behav_dir = '/Users/emilyhahn/projects/msit_modeling/behavior_preproc/raw/';
dir = '/Users/emilyhahn/projects/msit_modeling/behavior_preproc/';
%figs = fullfile(dir,'figures');

%% Main loop.
for n = 1:length(subjects)
        
    %% Load data.
    subject = subjects{n};

%% AY_You might check the file path    
    %% Load data
    load([behav_dir subject '_msit_raw_V2.mat']);
    
    %% Define model parameters.
    % Define dependent variables.
    K = length(logRT);
    Yn = log(RT);
    Yb = zeros(K,1);
    
    %% Define design matrices.
    In = ones(K,3);
    In(:,1) = Intercept;
    In(:,2) = Interference;
    In(:,3) = Intercept;
    Ib = In;
    % valid data points
    valid = 1 - Missing;
    Uk = zeros(K,1);
    
    %[a,b,c_extra]=glmfit(In(:,2),Yn,'normal');
    
    %% First step, build state space model - create behavioral model
    Param = compass_create_state_space(2,1,3,3,eye(2,2),[2 3],[0 0],[2 3],[0 0]);
    %Param.Vk = c_extra.sfit;

    %% Second step, define learning parameters
    Iter = 250;
    Param = compass_set_learning_param(Param,Iter,0,1,1,1,1,1,1,2,1); 
    
    %% Third Step, EM Algorithm
    DISTR = [1 0];
    [XSmt,SSmt,Param,XPos,SPos,ML,YN,YP]=compass_em(DISTR,Uk,In,Ib,Yn',Yb',Param,valid);
%% AY_You might want to take this part out   
    %% Plot Section
    figure(1)
    ind=find(Interference);
    plot(1:length(Yn),Yn,'LineWidth',3);hold on;
    plot(ind,Yn(ind),'o','LineWidth',3);hold on;
    plot(1:length(Yn),YN,'LineWidth',3);hold off;
    ylabel('Reaction Time (sec)')
    xlabel('Trial Index')
    hold off
    title('Behavioral Signal')
    f1 = [dir filesep 'figures' filesep subject '_BehavSig.png'];
    saveas(gcf,f1);


    figure(3)
    subplot(2,1,1)
    hh=1;
    K  = length(Yn);
    xm = zeros(K,1);
    xb = zeros(K,1);
    for i=1:K
        temp=XSmt{i};xm(i)=temp(hh);
        temp=SSmt{i};xb(i)=temp(hh,hh);
    end
    compass_plot_bound(1,(1:K),xm,(xm-2*sqrt(xb))',(xm+2*sqrt(xb))');
    ylabel(['x_' num2str(hh) '_k']);
    xlabel('Trial');
    axis tight

    subplot(2,1,2)
    hh=2;
    K  = length(Yn);
    xm = zeros(K,1);
    xb = zeros(K,1);
    for i=1:K
        temp=XSmt{i};xm(i)=temp(hh);
        temp=SSmt{i};xb(i)=temp(hh,hh);
    end
    compass_plot_bound(1,(1:K),xm,(xm-2*sqrt(xb))',(xm+2*sqrt(xb))');
    ylabel(['x_' num2str(hh) '_k']);
    xlabel('Trial');
    axis tight
    f3 = [dir filesep 'figures' filesep subject '_Xk.png'];
    saveas(gcf,f3);

    figure(4)
    for i=1:Iter
        ml(i)=ML{i}.Total;
    end
    plot(ml,'LineWidth',2);
    ylabel('ML')
    xlabel('Iter');
    title('Maximum Likelihood Curve')
    f4 = [dir filesep 'figures' filesep subject '_MLcurve.png'];
    saveas(gcf,f4);

    figure(5)
    ind = find(valid==0);
    Yn(ind)=YN(ind)+sqrt(Param.Vk)*ones(length(ind),1);
    acf((Yn-YN')',10)
    f5 = [dir filesep 'figures' filesep subject '_Autocorr.png'];
    saveas(gcf,f5);

    %% Fourth step: Save.
    out_dir = fullfile(behav_dir,'completed');
    f = [dir filesep 'completed' filesep subject '_msit_ss_V2.mat'];
    save(f)
    clear;
    
end

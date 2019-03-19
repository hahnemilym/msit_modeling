%behav_dir = '/Users/emilyhahn/projects/msit_modeling/behavior_preproc/raw/';
%subjects = {'hc001'}
subjects = {'hc001','hc002','hc003','hc004','hc005','hc006','hc007','hc008','hc009','hc010',...
              'hc011','hc012', 'hc013','hc014','hc015','hc016','hc017','hc018','hc019','hc020',...
              'hc021','hc022','hc023','hc024', 'hc025','hc026','hc028','hc029','hc030','hc031',...
              'hc032','hc033','hc034','hc035','hc036', 'hc037','hc038','hc042','hc044','hc045',...
              'pp001','pp002','pp003','pp004','pp005','pp006', 'pp007','pp008','pp009','pp010',...
              'pp011','pp012','pp013','pp014','pp015','pp016'};

%% Main loop.
for n = 1:length(subjects)
        
    %% Load data
    behav_dir = '/Users/emilyhahn/projects/msit_modeling/behavior_preproc/raw/';
    subject = subjects{n};

    %% Load data

    %load([behav_dir subject '_msit_raw.mat'])
    %save([behav_dir subject '_msit_raw_NEW.mat']);
    
    load([behav_dir subject '_msit_raw_NEW.mat']);
    Trial=Trial(1:189);
    Accuracy=Accuracy(2:190);
    Intercept=Intercept(2:190);
    Interference=Interference(2:190);
    Missing=Missing(2:190);
    Onset=Onset(2:190);
    RT=RT(2:190);
    logRT=logRT(2:190);    
    save([behav_dir subject '_msit_raw_V2.mat']);
    
end
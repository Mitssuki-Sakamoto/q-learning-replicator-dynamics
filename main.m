addpath src/agent
addpath src/env
addpath src/expriment/
addpath src/evolutionary_dynamics
Main() %メイン関数のみ

function Main()
    class = 1;
    if class == 1
        matrixes = cat(3, [1,5;0,3], [1,5;0,3]);
    elseif class == 2
        matrixes = cat(3, [2,0;0,1], [1,0;0,2]);
    elseif class == 3
        matrixes = cat(3, [2,3;4,1], [3,2;1,4]);
    end
    datetimestr =  datestr(datetime('now'), "yyyy-mm-dd-HH-MM-SS");
    logdir = "outcomes/" + 'class' + class + '_' + datetimestr + '/';
    mkdir(logdir);
    mkdir(logdir+"csvs/");
    mkdir(logdir+"images/");
    alpha = 0.01;
    taus = [1,2,10];
    interval = 0.05;
    n_episodes = 10;
    mutationRateValues = [0.01, 0.05, 0.1, 0.2, 0.25];
    % 戦略(0.1, 0.9),(0.9, 0.1), (0.3, 0.3), (0.7, 0.7), (0.5, 0.7),
    % (0.7, 0.5), (0.7, 0.3), (0.3, 0.7)
    initQValues = cat(3,[[0;2],[2;0]],[[2;0],[0;2]],[[0;1],[0;1]],[[1;0],[1;0]],[[0;0],[1;0]],[[1;0],[0;0]],[[1;0],[0;1]],[[0;1],[1;0]]);
    initPopulations = cat(3,[[0.1; 0.9],[0.9; 0.1]],[[0.1; 0.9], [0.1; 0.9]],[[0.9; 0.1], [0.9; 0.1]],[[0.9; 0.1], [0.1; 0.9]], ...
        [[0.3; 0.7], [0.7; 0.3]], [[0.3; 0.7], [0.3; 0.7]], [[0.7; 0.3], [0.7; 0.3]], [[0.7; 0.3], [0.3; 0.7]], [[0.5; 0.5], [0.5; 0.5]]);
    tic;
    runReinforcementLearing(matrixes, alpha, taus, initQValues, n_episodes, logdir+"csvs/");
    toc;
    tic;
    calcQLearingDynamics(matrixes, alpha, taus, interval, logdir+"csvs/");
    toc;
    tic;
    runReplicatorDynamics(matrixes, mutationRateValues, initPopulations, n_episodes, logdir+"csvs/");
    toc;
    tic;
    calcReplicatorDynamics(matrixes, mutationRateValues, interval, logdir+"csvs/");
    toc;
    plotFigure(alpha, taus, initQValues, initPopulations, mutationRateValues, interval, logdir);
end

function runReinforcementLearing(matrixes, alpha, taus, initQValues, n_episodes, logdir)
    env = MatrixEnv(matrixes);
    actions = env.actions;
    for i = 1:length(taus)
        % 引数の分離
        tau = taus(i);
        gamma = 0.9;
        actionSelect = @(qValues) ActionSelect.boltzmannSelect(qValues, tau);
        agents(1) = QLearningAgent(alpha, gamma, actions, actionSelect);
        agents(2) = QLearningAgent(alpha, gamma, actions, actionSelect);
        for iq = 1:length(initQValues)
            agents(1).setQValue(MatrixEnv.ONLY_STATE, initQValues(:,1,iq).'/tau);
            agents(2).setQValue(MatrixEnv.ONLY_STATE, initQValues(:,2,iq).'/tau);
            logFileName = logdir + "q_learing_trajectory_tau_" + tau ...
                + "_inits" + iq +".csv";
            train(env, agents, n_episodes, logFileName);
        end
    end
end

function calcQLearingDynamics(matrixes, alpha, taus, interval, logdir)
    for i = 1:length(taus)
        % 引数の分離
        tau = taus(i);
        reinformentDynamics = @(x1, y1) qLearningDynamics(matrixes, [[x1;1-x1],[y1;1-y1]], alpha, tau);
        [x,y] = meshgrid(interval:interval:1-interval,interval:interval:1-interval);
        replicators = arrayfun(reinformentDynamics, x, y,'UniformOutput',false);
        dx1s = cellfun(@(dx1) dx1(1,1), replicators);
        dy1s = cellfun(@(dx2) dx2(1,2), replicators);
        csvwrite(logdir + "q_learing_replicator_dynamics_dx1_tau_" + tau + ".csv", dx1s);
        csvwrite(logdir + "q_learing_replicator_dynamics_dy1_tau_" + tau + ".csv", dy1s);
    end
end

function runReplicatorDynamics(matrixes, mutationRateValues, initPopulations, n_episodes, logdir)
    % 何期回すか
    N = 1000;
    % 人口の変化量の加減
    threshold = 0.00001;
    % 人口更新の刻み幅
    dt = 0.1;
    for i = 1:length(mutationRateValues)
        mutationValue = mutationRateValues(i);
        mutationRate = ones(2).*mutationValue;
        mutationRate(:, :, 2) = ones(2).*mutationValue;
        replicatorDynamics = @(populations) mutationReplicatorDynamics(matrixes, populations, mutationRate);
        for ip = 1:length(initPopulations)
            populations = initPopulations(:,:,ip);
            populationsHistories = culcDynamicsFor(replicatorDynamics, populations, N, threshold, dt);
            logFileName = logdir + "replicator_dynamics_trajectory_mutaion_value_" + mutationValue + "_inits"+ ip +".csv";
            csvwrite(logFileName, populationsHistories);
        end
    end
end

function calcReplicatorDynamics(matrixes, mutationRateValues, interval, logdir)
    for i = 1:length(mutationRateValues)
        mutationValue = mutationRateValues(i);
        mutationRate = ones(2).*mutationValue;
        mutationRate(:, :, 2) = ones(2).*mutationValue;
        replicatorDynamics = @(x1, y1) mutationReplicatorDynamics(matrixes, [[x1;1-x1],[y1;1-y1]], mutationRate);
        [x,y] = meshgrid(interval:interval:1-interval,interval:interval:1-interval);
        replicators = arrayfun(replicatorDynamics, x, y,'UniformOutput',false);
        dx1s = cellfun(@(dx1) dx1(1,1), replicators);
        dy1s = cellfun(@(dx2) dx2(1,2), replicators);
        csvwrite(logdir + "mutation_replicator_dynamics_dx1_mutation_rate" + mutationValue +".csv", dx1s);
        csvwrite(logdir + "mutation_replicator_dynamics_dy1_mutation_rate" + mutationValue +".csv", dy1s);
    end
end

function plotFigure(alpha, taus, initQValues, initPopulations, mutationRateValues, interval, logdir)
    [x,y] = meshgrid(interval:interval:1-interval,interval:interval:1-interval);
    csvsDir = logdir +"csvs/";
    imagesDir = logdir +"images/";
    for i = 1:length(taus)
        tau = taus(i);
        dx1LogfileName = csvsDir + "q_learing_replicator_dynamics_dx1_tau_" + tau + ".csv";
        dx1s = csvread(dx1LogfileName);
        dy1LogfileName = csvsDir + "q_learing_replicator_dynamics_dy1_tau_" + tau + ".csv";
        dy1s = csvread(dy1LogfileName);
        %max(max((dx1s.*dx1s+ dy1s.*dy1s)))^0.5
        quiver(x, y, dx1s, dy1s)
        f = gcf;
        pngFileName = imagesDir + "q_learing_replicator_dynamics_tau_" + tau + ".png";
        exportgraphics(f, pngFileName)
    end
    
    for i = 1:length(mutationRateValues)
        mutationValue = mutationRateValues(i);
        dx1LogfileName = csvsDir + "mutation_replicator_dynamics_dx1_mutation_rate" + mutationValue +".csv";
        dx1s = csvread(dx1LogfileName);
        dy1LogfileName = csvsDir + "mutation_replicator_dynamics_dy1_mutation_rate" + mutationValue +".csv";
        dy1s = csvread(dy1LogfileName);
        %max(max((dx1s.*dx1s+ dy1s.*dy1s)))^0.5
        quiver(x, y, dx1s, dy1s)
        f = gcf;
        pngFileName = imagesDir + "mutation_replicator_dynamics_mutation_rate" + mutationValue + ".png";
        exportgraphics(f, pngFileName)
    end
    
    for i = 1:length(taus)
        tau = taus(i);
        clf
        hold on
        for iq = 1:length(initQValues)
            logFileName = csvsDir + "q_learing_trajectory_tau_" + tau ...
            + "_inits" + iq +".csv";
            policies = csvread(logFileName);
            x = policies(:,1);
            y = policies(:,3);
            plot(x,y);
            scatter(x(end),y(end));
        end
        xlim([-0.01 1.01])
        ylim([-0.01 1.01])
        hold off
        f = gcf;
        pngFileName = imagesDir + "q_learing_trajectory_tau_" + tau + ".png";
        exportgraphics(f, pngFileName)
    end
    
    for i = 1:length(mutationRateValues)
        mutationValue = mutationRateValues(i);
        clf
        hold on
        for ip = 1:length(initPopulations)
            logFileName = csvsDir + "replicator_dynamics_trajectory_mutaion_value_" + mutationValue ...
                + "_inits"+ ip +".csv";
            populations = csvread(logFileName);
            x = populations(:,1);
            y = populations(:,3);
            plot(x,y);
            scatter(x(end),y(end));
        end
        xlim([-0.01 1.01])
        ylim([-0.01 1.01])
        hold off
        f = gcf;
        pngFileName = imagesDir + "replicator_dynamics_trajectory_mutaion_value_" + mutationValue + ".png";
        exportgraphics(f, pngFileName)
    end
    
end

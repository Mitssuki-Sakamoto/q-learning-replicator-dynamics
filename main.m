addpath src/agent
addpath src/env
addpath src/expriment/
addpath src/evolutionaly_dynamics
Main() %メイン関数のみ

function Main()
    class = 3;
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
    alpha = 0.005;
    taus = [1,2,10];
    interval = 0.05;
    n_episodes = 4000;
    tic;
    reinforcementLearing(matrixes, alpha, taus, n_episodes, logdir);
    toc;
    tic;
    reinformentReplicators(matrixes, alpha, taus, interval, logdir);
    toc;
    plotFigure(alpha, taus, interval, logdir);
end

function reinforcementLearing(matrixes, alpha, taus, n_episodes, logdir)
    env = MatrixEnv(matrixes);
    actions = env.actions;
    for i = 1:length(taus)
        % 引数の分離
        tau = taus(i);
        gamma = 0.9;
        actionSelect = @(qValues) ActionSelect.boltzmannSelect(qValues, tau);
        agents(1) = QLearningAgent(alpha, gamma, actions, actionSelect);
        agents(2) = QLearningAgent(alpha, gamma, actions, actionSelect);
        % 戦略(0.1, 0.9),(0.9, 0.1), (0.3, 0.3), (0.7, 0.7), (0.5, 0.7),
        % (0.7, 0.5), (0.7, 0.3), (0.3, 0.7)
        initQValues = [[0,2;2,0],[2,0;0,2],[0,1;0,1],[1,0;1,0],[0,0;1,0],[1,0;0,0],[1,0;0,1],[0,1;1,0]];
        for qv = 1:2:length(initQValues)
            agents(1).setQValue(MatrixEnv.ONLY_STATE, initQValues(1,qv:qv+1)/tau);
            agents(2).setQValue(MatrixEnv.ONLY_STATE, initQValues(2,qv:qv+1)/tau);
            logFileName = logdir + "q_learing_trajectory_tau_" + tau ...
                + "_s" + ((qv+1)/2) +".csv";
            train(env, agents, n_episodes, logFileName);
        end
    end
end

function reinformentReplicators(matrixes, alpha, taus, interval, logdir)
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

function plotFigure(alpha, taus, interval, logdir)
    [x,y] = meshgrid(interval:interval:1-interval,interval:interval:1-interval);
    for i = 1:length(taus)
        tau = taus(i);
        dx1LogfileName = logdir + "q_learing_replicator_dynamics_dx1_tau_" + tau + ".csv";
        dx1s = csvread(dx1LogfileName);
        dy1LogfileName = logdir + "q_learing_replicator_dynamics_dy1_tau_" + tau + ".csv";
        dy1s = csvread(dy1LogfileName);
        %max(max((dx1s.*dx1s+ dy1s.*dy1s)))^0.5
        quiver(x, y, dx1s, dy1s)
        f = gcf;
        pngFileName = logdir + "q_learing_replicator_dynamics_tau_" + tau + ".png";
        exportgraphics(f,pngFileName)
    end
    
    initQValues = [[0,2;2,0],[2,0;0,2],[0,1;0,1],[1,0;1,0],[0,0;1,0],[1,0;0,0],[1,0;0,1],[0,1;1,0]];
    for i = 1:length(taus)
        tau = taus(i);
        clf
        hold on
        for qv = 1:2:length(initQValues)
            logFileName = logdir + "q_learing_trajectory_tau_" + tau ...
            + "_s" + ((qv+1)/2) +".csv";
            policies = csvread(logFileName);
            x = policies(:,1);
            y = policies(:,3);
            plot(x,y);
        end
        xlim([0 1])
        ylim([0 1])
        hold off
        f = gcf;
        pngFileName = logdir + "q_learing_trajectory_tau_" + tau + ".png";
        exportgraphics(f,pngFileName)
    end
end

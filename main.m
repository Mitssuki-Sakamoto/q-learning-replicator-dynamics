addpath src/agent
addpath src/env
addpath src/expriment/
addpath src/evolutionaly_dynamics
Main() %メイン関数のみ

function Main()
    matrixes = cat(3, [1,5;0,3], [1,5;0,3]);
    datetimestr =  datestr(datetime('now'), "yyyy-mm-dd-HH-MM-SS");
    logdir = "outcomes/" + datetimestr;
    mkdir(logdir);
    alpha = 0.02;
    taus = [1,2,10];
    interval = 0.05;
    n_episodes = 200;
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
        initQValues = [10,10;0,1;0,2;1,0;2,0];
        for qv1 = 1:length(initQValues) 
            for qv2 = 1:length(initQValues)
                agents(1).setQValue(MatrixEnv.ONLY_STATE, initQValues(qv1,:)/tau);
                agents(2).setQValue(MatrixEnv.ONLY_STATE, initQValues(qv2,:)/tau);
                logFileName = logdir + "/q_learing_trajectory_tau_" + tau ...
                    + "s1_" + qv1 + "_s2_" + qv2 +".csv";
                train(env, agents, n_episodes, logFileName);
            end
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
        csvwrite(logdir + "/q_learing_replicator_dynamics_dx1_tau_" + tau + ".csv", dx1s);
        csvwrite(logdir + "/q_learing_replicator_dynamics_dy1_tau_" + tau + ".csv", dy1s);
    end
end

function plotFigure(alpha, taus, interval, logdir)
    [x,y] = meshgrid(interval:interval:1-interval,interval:interval:1-interval);
    for i = 1:length(taus)
        tau = taus(i);
        dx1LogfileName = logdir + "/q_learing_replicator_dynamics_dx1_tau_" + tau + ".csv";
        dx1s = csvread(dx1LogfileName);
        dy1LogfileName = logdir + "/q_learing_replicator_dynamics_dy1_tau_" + tau + ".csv";
        dy1s = csvread(dy1LogfileName);
        quiver(x, y, dx1s, dy1s)
        f = gcf;
        pngFileName = logdir + "/q_learing_replicator_dynamics_tau_" + tau + ".png";
        exportgraphics(f,pngFileName)
    end
    
    for i = 1:length(taus)
        tau = taus(i);
        initQValues = [0,0;0,1;0,2;1,0;2,0];
        clf
        hold on
        for qv1 = 1:length(initQValues) 
            for qv2 = 1:length(initQValues)
                logFileName = logdir + "/q_learing_trajectory_tau_" + tau ...
                    + "s1_" + qv1 + "_s2_" + qv2 +".csv";
                policies = csvread(logFileName);
                x = policies(:,1);
                y = policies(:,3);
                plot(x,y);

            end
        end
        xlim([0 1])
        ylim([0 1])
        hold off
        f = gcf;
        pngFileName = logdir + "/q_learing_trajectory_tau_" + tau + ".png";
        exportgraphics(f,pngFileName)
    end
end

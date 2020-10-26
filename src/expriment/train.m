function episodeHistories = train(env, agents, nEpisodes, logFileName)
    nAgents = length(agents);
    % 2ではなく行動数
    episodeHistories=zeros(nEpisodes+1,nAgents*2);
    for a = 1:nAgents
        policy(a) = values(agents(a).policyMap);
    end
    policy = cell2mat(policy);
    episodeHistories(1,:) = policy;
    for n = 1:nEpisodes
        states = env.reset();
        totalReward = zeros(1,nAgents);
        dones = false(1,nAgents);
        for a = 1:nAgents
            agents(a).reset();
        end
        while ~dones
            actions = zeros(1,nAgents);
            for a = 1:nAgents
                actions(a) = agents(a).act(states(a));
            end
            [nextStates, rewards, dones] = env.step(actions);
            totalReward = totalReward + rewards;
            for a = 1:nAgents
                agents(a).updatePolicy(states(a), actions(a), rewards(a), nextStates(a));
            end
            states = nextStates;
        end
        policy = {};
        for a = 1:nAgents
            policy(a) = values(agents(a).policyMap);
        end
        policy = cell2mat(policy);
        episodeHistories(n+1,:) = policy;
    end
end
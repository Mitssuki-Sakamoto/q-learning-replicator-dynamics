classdef MatrixGame
    %MATRIXGAME このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        payoffMatrix
    end
    
    methods
        function obj = MatrixGame(payoffMatrix)
            %MATRIXGAME このクラスのインスタンスを作成
            %   詳細説明をここに記述
            obj.payoffMatrix = payoffMatrix;
        end
        
        function payoffs = payoffs_between_strategies(obj, strategies)
            %METHOD1 このメソッドの概要をここに記述
            %   詳細説明をここに記述
                
        end
    end
end


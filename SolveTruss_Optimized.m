function [MaxForce, MaxIndex, Displacement] = SolveTruss_Optimized(node)
    
    % Parameters
    NUM_ELEM = 18;
    NUM_NODE = 10;
    AE = 2.0e5;
    LINK = [1 2; 1 3; 2 3; 2 4; 2 5; 3 5; 3 6; 4 5; 5 6; 4 7; 4 8; 5 8; 5 9; 6 9; 6 10; 7 8; 8 9; 9 10];
    EXT_FORCE = zeros(NUM_NODE * 2,1);
    EXT_FORCE(1) = 2000;  % 2000 pounds in the x direction on node 1.
    EXT_FORCE(2) = -1000; % -1000 pounds in the y direction on node 1.

    % Variables
    K = zeros(NUM_NODE * 2);
    InternalForce = zeros(NUM_ELEM, 1);
    Direction = zeros(NUM_ELEM, 2); % direction cosines column 1: L, column 2: M
    DeltaLength = zeros(NUM_ELEM, 1);
    Length = zeros(NUM_ELEM, 1);

    % Compute K Matrix
    for i = 1:NUM_ELEM
        elementVector = node(LINK(i, 1), :) - node(LINK(i, 2), :);
        Length(i) = norm(elementVector);
        Direction(i, :) = elementVector / Length(i);

        kax = AE/Length(i);
        T = kax * [ Direction(i, 1)^2,                       Direction(i, 1)*Direction(i, 2)
                    Direction(i, 1)*Direction(i, 2),  Direction(i, 2)^2];
        
        from = (2 * LINK(i,1) - 1):(2 * LINK(i,1));
        to = (2 * LINK(i,2) - 1):(2 * LINK(i,2));

        K(from,from) = K(from,from) + T;
        K(to,to) = K(to,to) + T;
        K(from,to) = K(from,to) - T;
        K(to,from) = K(to,from) - T;
    end


    % Compute Displacement
    Kred = K;
    Fred = EXT_FORCE;
    Kred(20,:) = []; % reduce matricies
    Kred(:,20) = [];
    Kred(13:14,:) = [];
    Kred(:,13:14) = [];
    Fred(20) = [];
    Fred(13:14) = [];
    Displacement = linsolve(Kred, Fred);
    Displacement = [Displacement(1:12);0.0;0.0;Displacement(13:17);0.0];  % Add 0 disp to column vector
    DCopy = Displacement;
    Displacement = zeros(NUM_NODE, 2);
    for i = 1:NUM_NODE
        Displacement(i, :) = DCopy(i*2-1:i*2);
    end

    % Calculate Internal Forces
    for i = 1:NUM_ELEM
        % Correct DeltaLength calculation
        % DeltaLength(i) = norm(Direction(i,:) * Length(i) + Displacement(LINK(i, 2),:) - Displacement(LINK(i, 1),:)) - Length(i);
        
        DeltaLength(i) = sum(Direction(i,:).*-1.*(Displacement(LINK(i, 2),:) - Displacement(LINK(i, 1),:))); % Momot's DeltaLength
        InternalForce(i) = AE * DeltaLength(i) / Length(i);
    end
    
    [MaxForce, MaxIndex] = max(abs(InternalForce));
end
        

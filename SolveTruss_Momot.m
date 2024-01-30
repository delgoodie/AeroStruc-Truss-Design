function [MaxForce, MaxIndex, Displacements] = SolveTruss_Momot(node, OPTIMIZE)


%    Dr. Mike Momot,  November 13, 2023
% Last modified 12/8/2022. Convert displacement to local coords. Runs well.
% Description:  Determines the forces in a 2-D truss.  The truss is
% composed of triangles.  There are 10 nodes and 18 elements (rods).
% Node (7) must be at (0",0"), Node (10) must be at (36",0), and node (1) 
% must be 36 inches high (x can be anything between 0 and 36). Nodes may
% not be closer than 0.1"
% The truss is simply supported at the ground.
% Below is the truss configuration, with side nodes labeled.
%
%             | 1000# 
%             V
%     2000#->  o (1)
%            / \
%       (2) o---o  (3)
%          / \ / \
%     (4) o---o---o  (6)
%        / \ / \ / \ 
%   (7) o---o---o---o  (10)  
%       ^           O  
% Input: 
%   Input location (x,y) of each node into a file called Set_10_FEA_F23.txt
%   Data file should be located in the same directory as the program 
%   Set_10_FEA_F23.m  Units should be in inches
% Output: Forces in each element, in pounds
%
%__________________________Part 1: Definitions_________________________
% Define constants and get input values:
%
% Get x data....each value must be on a different line in file
% fid = fopen('Set_10_FEA_F23.txt','r');
% x(1:10) = 0.0;    % save space for x data
DigitsOld = digits(50);  % Higher precision
% ========= CHANGED ========
if isempty(node)
     node = readmatrix('Set_10_FEA_F23.txt');  % (x,y) location of each node
end
% ========== ==========
 x = node(:,1);  % x locations of nodes
 y = node(:,2);  % y locations of nodes
% fclose(fid);

DEBUG = false;
K = zeros(20); % Global stiffness matrix
AE = 2.0e5;  % 1060 Aluminum rod which is 0.5" in diameter = 2.0e6
nele = 18;   % Number of elements (#links = 18)
nnode = 10;  % Number of nodes
dL = zeros(nele); % Change in length array
Force = zeros(nnode);
% Define link connections.  Connections are: (from node, to node)
link = [1 2;1 3;2 3;2 4;2 5;3 5;3 6;4 5;5 6;4 7;4 8;5 8];
link = [link;5 9;6 9;6 10;7 8;8 9;9 10];
L = zeros(1,nele);    % Direction cosine (angle from x-axis)
M = zeros(1,nele);    % Direction cosine (angle from y-axis)
% Define global force vector.  Set unknown forces to zero.
% 20 forces = 10 nodes *2 forces (x,y)/node
% Odd values are x forces, even values are y forces.
% 1 is at top, (13,14) are lower left, (19,20) are lower right
F = zeros(20,1);
Force = zeros(20,1);
F(1) = 2000;  % 2000 pounds in the x direction on node 1.
F(2) = -1000; % -1000 pounds in the y direction on node 1.
if DEBUG
  F(13)= -F(1);             % sum forces in x direction
  F(14)=(F(2)*(x(1)-36)-F(1)*36.0)/36.0;   % sum moments about right side 
  F(20)= -(F(2)+F(14));     % sum forces in y direction
  fprintf("Supports F13=%8.1f\tF14=%8.1f\tF20=%8.1f\n",F(13),F(14),F(20));
end

% Initialize vectors.  
D(1:2*nnode) = 0;  % Displacement array
% y...20 = 2*nodes (x and y displ)
Len(1:nele) = 0;   % Array for length of each link
Disp(1:nele) = 0;  % Array for Displacement of each link
Force(1:nele) = 0; % Axial force vector

%__________Part 2: Form the Total K matrix____________________________
% Based upon node positions, determine direction cosines of elements
for R=1:nele  % R = row...cycle through all elements
    fn = link(R,1);  % From node
    tn = link(R,2);  % To node
    xf = node(fn,1); % x value of "from node"
    yf = node(fn,2); % y value of "from node"
    xt = node(tn,1); % x value of "to node"
    yt = node(tn,2); % y value of "to node"
    Len(R) = sqrt((xt-xf)^2+(yt-yf)^2); % length of element

    % Get direction cosines:
    % The following has signs.  Mistake in textbook.
        % Check the following....%
    L(R) = (xt-xf)/Len(R);
    M(R) = (yt-yf)/Len(R);
%       The following, from textbook, does not incorporate any sign
%     L(R) = cos(atan((yt-yf)/(xt-xf)));
%     M(R) = cos(atan((xt-xf)/(yt-yf)));
    if DEBUG 
       fprintf('RLM %d %8.5f %8.5f \n',R,L(R),M(R)); % Used for debug
    end

    % Find K matrix for element.
    kax = AE/Len(R);  % spring rate along bar; local coordinates
    T = kax*[L(R)^2 L(R)*M(R); L(R)*M(R) M(R)^2]; % Global coordinates
    i = 2*fn-1;  % adjust "from" index
    j = 2*tn-1;  % adjust "to" index
    % Add each element to the total K matrix
    K(i:i+1,i:i+1) = K(i:i+1,i:i+1) + T(1:2,1:2);  % Quadrant 1:1
    K(j:j+1,j:j+1) = K(j:j+1,j:j+1) + T(1:2,1:2);  % Quadrant 2:2
    K(i:i+1,j:j+1) = K(i:i+1,j:j+1) - T(1:2,1:2);  % Quadrant 1:2
    K(j:j+1,i:i+1) = K(j:j+1,i:i+1) - T(1:2,1:2);  % Quadrant 2:1
end
%_________________Part 3: Find Displacements & External Forces_________
% Reduce K...remove rows/cols 13, 14 and 20 
% These are the pivots with zero displacement, (can check forces)
% Always nullify higher rows/cols first to maintain proper numbering
Kred = K; % reduced K
Fred = F; % reduced F
Kred(20,:) = [];      % Nullify row 20
Kred(:,20) = [];      % Nullify col 20
Kred(13:14,:) = [];   % Nullify rows 13 and 14
Kred(:,13:14) = [];   % Nullify cols 13 and 14
Fred(20) = [];        % Nullify row 20 of the forces
Fred(13:14) = [];     % Nullify rows 13 and 14 of the forces
%!!!!!!!!!!!!!Does K need to be transposed?????
D = inv(Kred)*Fred;  % Find displacements
D = [D(1:12);0.0;0.0;D(13:17);0.0];  % Add 0 disp to column vector
F = K*D;
% ========= ADDED ========
Displacements = D;
% ========== ==========

%________________Part 4: Determine Internal Forces in Elements_________

% Determine change in length for each element (link), and force
for R=1:nele
    fn = link(R,1);   % From node
    tn = link(R,2);   % To node
    dxf = D(fn*2-1);  % change in x value of "from node"
    dyf = D(fn*2);    % change in y value of "from node"
    dxt = D(tn*2-1);  % change in x value of "to node" 
    dyt = D(tn*2);    % change in y value of "to node"

    xf = node(fn,1);  % x value of "from node"
    yf = node(fn,2);  % y value of "from node"
    xt = node(tn,1);  % x value of "to node"
    yt = node(tn,2);  % y value of "to node"
     
    % Added 12/8/2022 to fix errors. Answers checked and are good.
    theta = atan2(yt-yf,xt-xf);
    Ct = cos(theta); St = sin(theta);
    
    % Determine the change in overall length
    dLen = Ct*(dxt-dxf)+St*(dyt-dyf);   % New and improved
    dL(R) = dLen*100;   % Store change in length in hundredths of inch
        % Check the following....%
    Force(R) = AE*dLen/Len(R);  % Force in each link, F=A(E*strain)
end

[FM, I] = max(abs(Force));
% ========= ADDED ========
MaxForce = FM;
MaxIndex = I;

if ~OPTIMIZE
    fprintf('Maximum force is :\n');
    fprintf('%7d %9.2f\n', I, FM);

% Plot the links and their displacements
% Added 11/11/2022
    clf
    hold on     % allows overplot of other lines
    for R=1:nele
        fn = link(R,1);   % From node
        tn = link(R,2);   % To node
    
        xf = node(fn,1);  % x value of "from node"
        yf = node(fn,2);  % y value of "from node"
        xt = node(tn,1);  % x value of "to node"
        yt = node(tn,2);  % y value of "to node"
    
        dxf = D(fn*2-1)+xf;  % deformed x value of "from node"
        dyf = D(fn*2)+yf;    % deformed y value of "from node"
        dxt = D(tn*2-1)+xt;  % deformed x value of "to node" 
        dyt = D(tn*2)+yt;    % deformed y value of "to node"
    
        plot([xf,xt],[yf yt],'k'); % original configuration
        if R == I
            plot([dxf,dxt],[dyf,dyt],'b'); % blue link shows maximum force
        else
            plot([dxf,dxt],[dyf,dyt],'r'); % red links are displaced
        end
    end
    hold off  % plot all of above and get ready for next plot
end

digits(DigitsOld); % restore precision
end
    
        

close all
clc
clear
warning('off','all')
warning

NUM_ELEM = 18;
LINK = [1 2; 1 3; 2 3; 2 4; 2 5; 3 5; 3 6; 4 5; 5 6; 4 7; 4 8; 5 8; 5 9; 6 9; 6 10; 7 8; 8 9; 9 10];


r0_sym = NodeToPosition([36/2, 36
                    2/5*36, 2/3*36 ; 3/5*36, 2/3*36
        2/6*36, 1/3*36 ; 3/6*36, 1/3*36 ; 4/6*36, 1/3*36
        0 0 ; 1/3*36, 0; 2/3*36, 0; 36, 0]);

r0_ashlyn = NodeToPosition([0 36 ; 3 24 ; 4 36 ; 2 12 ; 16 16 ; 36 3 ; 0 0 ; 3 0 ; 20 0 ; 36 0]);
r0_demo = [11.5; 11.5; 35.5; 22.5; 21.5; 7; 18; 13; 21; 36; 1; 22; 0; 35.5; 0];


gen_r0s = readmatrix('ResultData.txt');

for k=1:length(gen_r0s)/10
    curNode = gen_r0s(k*10-9:k*10, :);
    [f0, maxIndex] = CalculateMaxForce(curNode);
    clf
    hold on
    for i = 1:NUM_ELEM
        if i==maxIndex
            plot(curNode(LINK(i,:),1), curNode(LINK(i,:),2), 'b');
            text(sum(curNode(LINK(i,:),1))/2, sum(curNode(LINK(i,:),2))/2, string(f0))
        else
            plot(curNode(LINK(i,:),1), curNode(LINK(i,:),2), 'r');
        end
    end
    for i = 1:10
        text(curNode(i,1),curNode(i,2), string(i))
    end
    hold off
    %pause(.5);
end




% Parameters
h = .06;
gh = .1;
r0 = r0_sym;
n = 5000;
slomo = 1;
show_plot = 1;

global_best_f = 3e3;
global_best_r = 0;

iter = 0;
while 1
    iter = iter + 1;
    if mod(iter, 100) == 0
        disp(iter)
    end
    close all

    %r0 = NodeToPosition(rand(10, 2) * 36);
    %h = rand() * .1 + .001;
    %gh = rand() * 2 + .001;

    % Variables
    r_best = r0;
    f_best = CalculateMaxForce(PositionToNode(r0));
    r = r0;
    f0 = f_best;
    %fig = figure;
    for k = 1:n
        [f0, maxIndex] = CalculateMaxForce(PositionToNode(r));
    
        if f0 < f_best
            f_best = f0;
            r_best = r;
            if f0 < global_best_f
                global_best_f = f0;
                global_best_r = r;
                disp(global_best_f)
                disp(PositionToNode(global_best_r))
            end
        end
    
        % Plotting
        if slomo < 1
            pause(.01 / slomo)
        end
        if show_plot && mod(k, 10) == 1
            clf
            hold on
            curNode = PositionToNode(r);
            for i = 1:NUM_ELEM
                if i==maxIndex
                    plot(curNode(LINK(i,:),1), curNode(LINK(i,:),2), 'b');
                    text(sum(curNode(LINK(i,:),1))/2, sum(curNode(LINK(i,:),2))/2, string(f0))
                else
                    plot(curNode(LINK(i,:),1), curNode(LINK(i,:),2), 'r');
                end
            end
            for i = 1:10
                text(curNode(i,1),curNode(i,2), string(i))
            end
            hold off
            pause(.001);
        end
    
        % Step
        step = CalculateStep(r, f0, h, gh);
        r = StepPosition(r, step);
        
        if isnan(r)
            break
        end
    end
end

% f_best
% PositionToNode(r_best)
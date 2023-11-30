close all
clc
clear
warning('off','all')

NUM_ELEM = 18;
LINK = [1 2; 1 3; 2 3; 2 4; 2 5; 3 5; 3 6; 4 5; 5 6; 4 7; 4 8; 5 8; 5 9; 6 9; 6 10; 7 8; 8 9; 9 10];

% Parameters
h = .06;
gh = .1;
num_iterations = 5000;
num_trials = 10000;
slomo = 1;
show_plot = 1;

global_best_f = 10e10;
global_best_r = [];

% Multiple trials with different initial positions
for trial = 1:num_trials
    if mod(trial, 50) == 0
        disp(trial)
    end
    close all

    %h = rand() * .1 + .001;
    %gh = rand() * 2 + .001;

    % Variables
    r = chooseInitialPosition(trial);
    r_best = r;
    f_best = SolveTruss_Optimized(PositionToNode(r));
    f0 = f_best;

    % Iterative Search
    for it = 1:num_iterations
        [f0, maxIndex] = SolveTruss_Optimized(PositionToNode(r));
    
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
    
        % Plot
        if show_plot && mod(it, 10) == 1
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
        if slomo < 1
            pause(.01 / slomo)
        end
    
        % Step
        step = CalculateStep(r, f0, h, gh);
        r = StepPosition(r, step);
        
        if isnan(r)
            break
        end
    end
end
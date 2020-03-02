function [answer,consecutive] = intprog_scheduling(D_matrix,n)
% D_matrix is an nxn symmetric matrix s.t. the (i,j) entry corresponds to
% the number of students enrolled in both classes. 
% n is the number of classes


% First, let's vectorize the D_matrix...
d_vector = [];
tracker = 0;
for row = 1:n
    for col = 1:n
        tracker = tracker + 1;
        d_vector(tracker) = D_matrix(row,col);
    end
end

% Solution vector is a matrix where row = slot, col = class

% Constraint 1: Each slot has only one class
A1 = zeros(n,n^2);
for row = 1:n
    for class = 1:n
        A1(row,class + (row-1)*n) = 1;
    end
end
b1 = ones(n,1);

% Constraint 2: Each class belongs to only one slot
A2 = zeros(n,n^2);
for col = 1:n
    for slot = 1:n
        A2(col,col + (slot-1)*n) = 1;
    end
end
b2 = ones(n,1);

% Now, we must exted the matrices to include our slack variables that we
% are about to introduce
A1 = [A1,zeros(n,n^3-n^2)];
A2 = [A2,zeros(n,n^3-n^2)];

% Setting up slack variables
A3 = zeros(n^2*(n-1),n^3);
counter = 0;
for tran = 1:n-1
    for first = 1:n
        for second = 1:n
            counter = counter + 1;
            for entry = 1:3
                if entry == 1
                    A3(counter,(tran-1)*n + first) = 1;
                elseif entry == 2
                    A3(counter,(tran-1)*n + n + second) = 1;
                else
                    A3(counter,n^2 + counter) = -1;
                end
            end
        end
    end
end
b3 = ones(n^2*(n-1),1);

f_beg = zeros(1,n^2); 
f_end = repmat(d_vector,1,n-1);
f = [f_beg,f_end];

        
Aeq = [A1;A2;A3];
beq = [b1;b2;b3];

sol = intlinprog(f,[1:n^3],[],[],Aeq,beq,-1*ones(n^3,1),ones(n^3,1));

% Decoding the answer

answer = zeros(1,n);
for slot = 1:n
    for entry = 1:n
        if sol(entry + (slot-1)*n) == 1
            answer(slot) = entry;
        end
    end
end

sol(sol == -1) = 0;
consecutive = f*sol;





 



    




            
            


        
        
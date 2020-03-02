function [answer,conflicts] = finals_scheduling(D)

[rows,cols] = size(D);
n = rows;

% Sum of variables equals n-1
A1 = ones(1,n^2*(n-1));
b1 = n-1;

% Each slot has only one selection
A2 = zeros(n-1,n^2*(n-1));
for slot = 1:n-1
    for entry = 1:n^2
        A2(slot,entry + (slot-1)*n^2) = 1;
    end
end
b2 = ones(n-1,1);

% If a class is selected as the endpoint of previous slot, that class must
% be the startpoint of the next slot
A3 = zeros((n-2)*n,n^2*(n-1));
tracker = 0;
for slot = 1:n-2
    for class = 1:n
        tracker = tracker + 1;
        for entry = 1:n
            A3(tracker, (slot-1)*n^2 + (entry-1)*n + class) = 1;
        end
    end
end

counter = 0;
for slot = 1:n-2
    for class = 1:n
        counter = counter + 1;
        for entry = 1:n
            A3(counter, slot*n^2 + (class-1)*n + entry) = -1;
        end
    end
end

counter = 0;
for slot = 1:n-2
    for class = 1:n
        counter = counter + 1;
        for entry = 1:n
            A3(counter, slot*n^2 + (class-1)*n + entry) = -1;
        end
    end
end
b3 = zeros((n-2)*n,1);

% Each class is visited at least one time (once for the endpoints, twice
% for every other one)
A4 = zeros(n,n^2*(n-1));
for class = 1:n
    for slot = 1:n-1
        for entry = 1:n
            A4(class, (slot-1)*n^2 + (class-1)*n + entry) = -1;
        end
    end
end
for class = 1:n
    for slot = 1:n-1
        for entry = 1:n
            A4(class, (slot-1)*n^2 + (entry-1)*n + class) = -1;
        end
    end
end
b4 = -1*ones(n,1);

% Constructing the objective function
d_vector = [];
tracker = 0;
for row = 1:n
    for col = 1:n
        tracker = tracker + 1;
        d_vector(tracker) = D(row,col);
    end
end
f = repmat(d_vector,1,(n-1));
f(isnan(f)) = max(D(:))*100000;

% Running the integer Program
A = [A4];
b = [b4];
Aeq = [A1;A2;A3];
beq = [b1;b2;b3];
[sol,fval] = intlinprog(f,[1:n^2*(n-1)],A,b,Aeq,beq,zeros(n^2*(n-1),1),ones(n^2*(n-1),1));
sol = round(sol);
conflicts = fval;

% Translating the solution
select = zeros((n-1),2);
for slot = 1:n-1
    for row = 1:n
        for col = 1:n
            if sol((slot-1)*n^2 + (row-1)*n + col,1) == 1
                select(slot,1) = row;
                select(slot,2) = col;
            end
        end
    end
end

answer = zeros(1,n);
for i = 1:n-1
    answer(i) = select(i,1);
end
answer(n) = select((n-1),2);

% Each column of the answer represents the slot, the entry is the class



        







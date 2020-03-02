function [completed_table] = sudoku_prog(entries)

% Each block (of which there are 81) must contain exactly one number
Atop = zeros(81,729);
for block = 1:81
    for selection = 1:9
        Atop(block,selection+((block-1)*9)) = 1;
    end
end
btop = ones(81,1);

% Each megarow contains one of each number
Amiddle = zeros(81,729);
counter = 0;
for row = 1:9
    for num = 1:9
        counter = counter + 1;
        for entry = 1:9
            Amiddle(counter,(row-1)*81+num+(entry-1)*9) = 1;
        end
    end
end
bmiddle = ones(81,1);

% Each megacolumn contains one of each number
Anext = zeros(81,729);
counter = 0;
for col = 1:9
    for num = 1:9
        counter = counter + 1;
        for entry = 1:9
            Anext(counter,(entry-1)*81+num+(col-1)*9) = 1;
        end
    end
end
bnext = ones(81,1);

% Each minigrid contains one of each number
Afinal = zeros(81,729);
counter = 0;
for megarow = 1:3
    for megacol = 1:3
        for num = 1:9
            counter = counter + 1;
            for entry = 1:9
                if entry == 1 || entry == 2 || entry == 3
                    Afinal(counter,(megacol-1)*27 + (megarow-1)*243 + num + (entry-1)*9) = 1;
                elseif entry == 4 || entry == 5 || entry == 6
                    Afinal(counter,(megacol-1)*27 + (megarow-1)*243 + num + (entry-4)*9 + 81) = 1;
                elseif entry == 7 || entry == 8 || entry == 9
                    Afinal(counter,(megacol-1)*27 + (megarow-1)*243 + num + (entry-7)*9 + 162) = 1;
                end
            end
        end
    end
end
bfinal = ones(81,1);

% Specifying the position of the numbers given as variables for the
% objective function to minimize
vectorized_entries = zeros(81,1);
count = 0;
for row = 1:9
    for col = 1:9
        count = count + 1;
        vectorized_entries(count) = entries(row,col);
    end
end

f = zeros(1,729);
entry_num = 0;
for index = 1:81
    if vectorized_entries(index) ~= 0
        entry_num = entry_num + 1;
        num = vectorized_entries(index);
        f((index-1)*9 + num) = 1;
    end
end
f = -1*f;

% Bringing it all together and using the intlinprog function

Aeq = [Atop;Amiddle;Anext;Afinal];
beq = [btop;bmiddle;bnext;bfinal];
[answer,fval,exitflag] = intlinprog(f,[1:729],[],[],Aeq,beq,zeros(729,1),ones(729,1));
        

% Decoding the answer
number = [];
answer = round(answer);
for block = 1:81
    for select = 1:9
        if answer((block-1)*9 + select) == 1
            number(block) = select;
        end
    end
end
table = zeros(9,9);
counter = 0;
for row = 1:9
    for col = 1:9
        counter = counter + 1;
        table(row,col) = number(counter);
    end
end
completed_table = table;
disp('Number of entries specified:')
disp(entry_num)
disp('Number of those entries in the solution:')
disp(-1*fval)




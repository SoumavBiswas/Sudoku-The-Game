function result=Solvesudoku(problem)
 if nargin==0
 problem=zeros(9);
 end
[r,c]=size(problem);
if ((r~=9)||(c~=9))
    error('Error !');
end
stat=Checkboard(problem);
if sum(sum(stat))~=0    
    error('Input problem violates Sudoku rules!');
end
board=problem;
possibility=cell(9);
for row=1:9
for col=1:9
 if problem(row,col)==0
    possibility{row,col}=[1,2,3,4,5,6,7,8,9];
 end
end
end
for row=1:9
for col=1:9
    if problem(row,col)~=0
        testvalue=problem(row,col);
    for count=1:9
    possibility{row,count}... 
    (possibility{row,count}==testvalue)=[];
    possibility{count,col}...
    (possibility{count,col}==testvalue)=[];
    end
minirow=ceil(row/3);
minicol=ceil(col/3);
for i=3*minirow-2:3*minirow
for j=3*minicol-2:3*minicol
    possibility{i,j}(possibility{i,j}==testvalue)=[];
end
end
    end

end
end
pivotvalue=cell(1,81);
pivotrow=cell(1,81);
pivotcol=cell(1,81);
pivotboard=cell(1,81);
pivotpossibility=cell(1,81);

pivot=0;
while sum(sum((board==0)))
    possibility=EliminateTwinsInRow(possibility);
    possibility=EliminateTwinsInCol(possibility);
    possibility=EliminateTwinsInMiniGrid(possibility);
    possibility=EliminateTripletsInRow(possibility);
        possibility=FindEliminateTripletsInCol(possibility);
        possibility=FindEliminateTripletsInMiniGrid(possibility);
        [value1,rowloc1,colloc1]=FindSinglePossibility(possibility);
        [board,possibility]=FillBoard(board,possibility,...
                                value1,rowloc1,colloc1);
        [value2,rowloc2,colloc2]=FindLoneRanger(possibility);
           [board,possibility]=FillBoard(board,possibility,...
                                      value2,rowloc2,colloc2);
        
        %Anticipating wrong guess and return to the closest pivot
        stat1=Checkboard(board);
        stat2=CheckImpossibility(board,possibility);
if (sum(sum(stat))~=0)||(sum(sum(stat2))~=0)
board=pivotboard{pivot};
possibility=pivotpossibility{pivot};
testvalue=pivotvalue{pivot}...
                               (ceil(rand*numel(pivotvalue{pivot})));
 pivotvalue{pivot}(pivotvalue{pivot}==testvalue)=[];
            [board,possibility]=FillBoard(board,possibility,testvalue,...
                                          pivotrow{pivot},pivotcol{pivot});
if isempty(pivotvalue{pivot})
   pivot=pivot-1;
end
end
%Guess value
 if(numel(value1)==0) && (numel(value2)==0)
    pivot=pivot+1;
    possibilitycount=CountPossibility(possibility);
    for count=2:9
    [rcandidate,ccandidate]=find(possibilitycount==count);
    if ~isempty(rcandidate)
        break
    end
    end
        if isempty(rcandidate)
        break
        else
            pivotrow{pivot}=rcandidate(1);
            pivotcol{pivot}=ccandidate(1);
        end
            testvalue=possibility{pivotrow{pivot},pivotcol{pivot}}...
                                 (ceil(rand*numel(possibility{...
                                                  pivotrow{pivot},...
                                                  pivotcol{pivot}})));
            pivotvalue{pivot}=possibility{pivotrow{pivot},pivotcol{pivot}};
            pivotvalue{pivot}(pivotvalue{pivot}==testvalue)=[];
            pivotboard{pivot}=board;
            pivotpossibility{pivot}=possibility;
            [board,possibility]=FillBoard(board,possibility,testvalue,...
                                          pivotrow{pivot},pivotcol{pivot});
 end
end
%Result generating
result=board;
end
        

%local fuctions
function stat=Checkboard(board)
stat=false(9);
for testvalue=1:9
    for row=1:9
    	if sum(sum(board(row,:)==testvalue))>1
        errlocation=(board(row,:)==testvalue);
        stat(row,:)=stat(row,:)|errlocation;
        end
    end
     for col=1:9
            if sum(sum(board(:,col)==testvalue))>1
                errlocation=(board(:,col)==testvalue);
                stat(:,col)=stat(:,col)|errlocation;
            end
     end
    for minirow=1:3
    for minicol=1:3
        if sum(sum(board(minirow*3-2:minirow,minirow*3-2:minirow)==...
            testvalue))
        errlocation=(board(minirow*3-2:minirow,minirow*3-2:minirow)==...
            testvalue);
        stat(minirow*3-2:minirow,minirow*3-2:minirow)=...
            stat(minirow*3-2:minirow,minirow*3-2:minirow)|errlocation;
        end
    end
    end
end
end
%function that checks impossibility
function stat=CheckImpossibility(board,possibility)
stat=false(9);
for row=1:9
for col=1:9
if (board(row,col)==0)&&(numel(possibility{row,col})==0)
    stat(row,col)=true;
end
end
end
end
%function that finds and eliminates twins in rows
function possibility=EliminateTwinsInRow(possibility)
for row=1:9
    for col=1:9
    if numel(possibility(row,col))==2
    t=zeros(1,9);
    for count=1:9
        t(count)=isequal(possibility{row,col},...
                        possibility{row,count});
    end
    if sum(sum(t))==2
        value1=possibility{row,col}(1);
        value2=possibility{row,col}(2);
        for count=1:9
            if t(count)~=1
            possibility{row,count}...
                        (possibility{row,count}==value1)=[];
            possibility{row,count}...
                        (possibility(row,count)==value2)=[];
            end
        end
    end
    end
    end
end
end
%Eliminate twins in column
function possibility=EliminateTwinsInCol(possibility)
for col=1:9
    for row=1:9
    if numel(possibility(row,col))==2
    t=zeros(9,1);
    for count=1:9
        t(count)=isequal(possibility{row,col},...
                        possibility{count,col});
    end
    if sum(sum(t)==2)
        value1=possibility{row,col}(1);
        value2=possibility{row,col}(2);
        for count=1:9
            if t(count)~=1
            possibility{count,col}...
                        (possibility{count,col}==value1)=[];
            possibility{row,count}...
                        (possibility(count,col)==value2)=[];
            end
        end
    end
    end
    end
end
end
%Eliminating twins in minigrid

            function possibility=EliminateTwinsInMiniGrid(possibility)
for row=1:9
    for col=1:9
    if numel(possibility(row,col))==2
    t=zeros(3);
    minrow=3*ceil(row/3);
    minicol=3*ceil(col/3);
    for count1=1:3
    for count2=1:3
         t(count1,count2)=isequal(possibility{row,col},...
                                            possibility{minicrow-3+count1,...
                                                        minicol-3+count2});
    end
    end
    if sum(sum(t)==2)
        value1=possibility{row,col}(1);
        value2=possibility{row,col}(2);
        for count1=1:3
        for count2=1:3
            if temp(count1,count2)~=1
                        possibility{minirow-3+count1,...
                                    minicol-3+count2}...
                                    (possibility{minirow-3+count1,...
                                                 minicol-3+count2}...
                                                 ==value1)...
                        =[];
                        possibility{minirow-3+count1,...
                                    minicol-3+count2}...
                                    (possibility{minirow-3+count1,...
                                                 minicol-3+count2}...
                                                 ==value2)...
                        =[];
             end
        end
         end
    end
    end
end
end
            end 
%Eliminate triplets from  Row
function possibility=EliminateTripletsInRow(possibility)
for row=1:9
for col=1:9
    if numel(possibility{row,col})==3
        t1=zeros(1,9);
        test1=possibility{row,col}([1,2]);
        t2=zeros(1,9);
        test2=possibility{row,col}([2,3]);
        t3=zeros(1,9);
        test3=possibility{row,col}([1,3]);
        t4=zeros(1,9);
      for count=1:9
        t1(count)=isequal(test1,possibility{row,count});
         t2(count)=isequal(test2,possibility{row,count});
         t3(count)=isequal(test3,possibility{row,count});
         t4(count)=isequal(test1,possibility{row,col},...
                                 possibility{row,count});
      end
        t=t1+t2+t3+t4;
       if sum(sum(t))==3
        value1=possibility{row,col}(1);
        value2=possibility{row,col}(2);
        value3=possibility{row,col}(3);

        for count=1:9
            if t(count)~=1
            possibility{row,count}...
                                    (possibility{row,count}==value1)=[];
            possibility{row,count}...
                                    (possibility{row,count}==value2)=[];
            possibility{row,count}...
                                    (possibility{row,count}==value3)=[];
            end
        end
       end
    end
end
end
end
%eliminate triplets in column

 function possibility=FindEliminateTripletsInCol(possibility)
for col=1:9
for row=1:9
    if numel(possibility{row,col})==3
        t1=zeros(9,1);
        test1=possibility{row,col}([1,2]);
        t2=zeros(9,1);
        test2=possibility{row,col}([2,3]);
        t3=zeros(9,1);
        test3=possibility{row,col}([1,3]);
        t4=zeros(9,1);
      for count=1:9
        t1(count)=isequal(test1,possibility{count,col});
         t2(count)=isequal(test2,possibility{count,col});
         t3(count)=isequal(test3,possibility{count,col});
         t4(count)=isequal(test1,possibility{row,col},...
                                 possibility{count,col});
      end
        t=t1+t2+t3+t4;
       if sum(sum(t))==3
        value1=possibility{row,col}(1);
        value2=possibility{row,col}(2);
        value3=possibility{row,col}(3);

        for count=1:9
            if t(count)~=1
            possibility{count,col}...
                                    (possibility{count,col}==value1)=[];
            possibility{count,col}...
                                    (possibility{count,col}==value2)=[];
            possibility{count,col}...
                                    (possibility{count,col}==value3)=[];
            end
        end
       end
    end
end
end
end
%eliminate triplets in minigrid
        function possibility=FindEliminateTripletsInMiniGrid(possibility)
for row=1:9
for col=1:9
    if numel(possibility{row,col})==3
        t1=zeros(3);
        test1=possibility{row,col}([1,2]);
        t2=zeros(3);
        test2=possibility{row,col}([2,3]);
        t3=zeros(3);
        test3=possibility{row,col}([1,3]);
        t4=zeros(3);
        minirow=3*ceil(row/3);
        minicol=3*ceil(col/3);
      for count1=1:3
       for count2=1:3
         temp1(count1,count2)=isequal(test1,...
                                             possibility{minirow-3+count1,...
                                                         minicol-3+count2});
                temp2(count1,count2)=isequal(test2,...
                                             possibility{minirow-3+count1,...
                                                         minicol-3+count2});
                temp3(count1,count2)=isequal(test3,...
                                             possibility{minirow-3+count1,...
                                                         minicol-3+count2});
                temp4(count1,count2)=isequal(possibility{row,col},...
                                             possibility{minirow-3+count1,...
                                                         minicol-3+count2});
       end
      end
        t=t1+t2+t3+t4;
       if sum(sum(t))==3
        value1=possibility{row,col}(1);
        value2=possibility{row,col}(2);
        value3=possibility{row,col}(3);

        for count1=1:3
        for count2=1:3
            if t(count1,count2)~=1
            possibility{minirow-3+count1,...
                                    minicol-3+count2}...
                                    (possibility{minirow-3+count1,...
                                                 minicol-3+count2}...
                                                 ==value1)...
=[];
            possibility{minirow-3+count1,...
                                    minicol-3+count2}...
                                    (possibility{minirow-3+count1,...
                                                 minicol-3+count2}...
                                                 ==value2)...
=[];
           possibility{minirow-3+count1,...
                                    minicol-3+count2}...
                                    (possibility{minirow-3+count1,...
                                                 minicol-3+count2}...
                                                 ==value3)...
=[];
                                    
            end
        end
        end
       end
    end
end
end
        end
%count possibility

 function posscount=CountPossibility(possibility)
 posscount=zeros(9)

for row=1:9
for col=1:9
    posscount(row,col)=numel(possibility{row,col});
end
end
 end


function [value,rowloc,colloc]=FindSinglePossibility(possibility)
    possibilitycount=CountPossibility(possibility);
    
    [rowloc,colloc]=find(possibilitycount==1);
    %Finding value to filled in
    value=zeros(size(rowloc));
    for count=1:numel(rowloc)
        value(count)=possibility{rowloc(count),colloc(count)};
    end
end

%--------------------------------------------------------------------------
function [value,rowloc,colloc]=FindLoneRanger(possibility)
    %Preparing result array
    value=[];
    rowloc=[];
    colloc=[];
    %Finding LoneRanger
    for row=1:9
    for col=1:9
        if ~isempty(possibility{row,col})
            testarray=possibility{row,col};
            gcrow=ceil(row/3);
            gccol=ceil(col/3);
            for testvalue=testarray
                temp1=zeros(1,9);
                temp2=zeros(9,1);
                temp3=zeros(3);
                for count=1:9
                    temp1(1,count)=sum(sum(possibility{row,count}...
                                           ==testvalue));
                    temp2(count,1)=sum(sum(possibility{count,col}...
                                           ==testvalue));
                end
                for count1=3*gcrow-2:3*gcrow
                for count2=3*gccol-2:3*gccol
                    temp3(count1,count2)=sum(sum(possibility{count1,...
                                                             count}...
                                                 ==testvalue));
                end
                end
                if (sum(sum(temp1))==1)||...
                   (sum(sum(temp2))==1)||...
                   (sum(sum(temp3))==1)
                    value(numel(value)+1)=testvalue;
                    rowloc(numel(rowloc)+1)=row;
                    colloc(numel(colloc)+1)=col;
                    break
                end
            end
        end
    end        
    end
end
    function [board,possibility]=FillBoard(board,possibility,...
                                       value,rowloc,colloc)
    if numel(value)~=0
    for count=1:numel(value)
        %Filling value to board
        board(rowloc(count),colloc(count))=value(count);
        %Updating possibility array
            possibility{rowloc(count),colloc(count)}=[];
            %Removing filled value in adjacent row
            for row=1:9
                possibility{row,colloc(count)}...
                (possibility{row,colloc(count)}==value(count))=[];
            end
            %Removing filled value in adjacent column
            for col=1:9
                possibility{rowloc(count),col}...
                (possibility{rowloc(count),col}==value(count))=[];
            end
            %Removing filled value in the same minigrid
            gcrow=ceil(rowloc(count)/3);
            gccol=ceil(colloc(count)/3);
            for i=3*gcrow-2:3*gcrow
            for j=3*gccol-2:3*gccol
                possibility{i,j}(possibility{i,j}==value(count))=[];
            end
            end
    end
    end
end


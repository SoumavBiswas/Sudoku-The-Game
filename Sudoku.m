function Sudoku
close all
clear all
% global variable
    board=zeros(9);
    stat=zeros(9);
% GUI Create
    SizeOfScreen=get(0,'ScreenSize');
    mainwindow=figure('Name','SudokuGame',...
                      'Resize','on',...
                      'Menubar','none',...
                      'Units','pixels',...
                      'Position',[0.5*(SizeOfScreen(3)-382),...
                                  0.5*(SizeOfScreen(4)-400),...
                                  384,400]);
    guiboard2=zeros(9);
    for i=1:9
       for j=1:9
            vertical=(ceil(j/3)-2)*0.0165;
            horizontal=(ceil(i/3)-2)*0.0165;
            guiboard2(i,j)=uicontrol('Parent',mainwindow,...
                                 'Style','edit',...
                                 'String','',...
                                 'Units','normalized',...
                                 'Position',[0.0975+0.075*i+horizontal,...
                                             0.975-0.075*j-vertical,...
                                             0.075,0.075]);
        end
    end
    uicontrol('Parent',mainwindow,...
              'Style','pushbutton',...
              'String','EasyMode',...
              'Units','normalized',...
              'Position',[0.1,0.2,0.25,0.05],...
              'Callback',@EasyModefcn);
    uicontrol('Parent',mainwindow,...
              'Style','pushbutton',...
              'String','NormalMode',...
              'Units','normalized',...
              'Position',[0.375,0.2,0.25,0.05],...
              'Callback',@NormalModefcn);
    uicontrol('Parent',mainwindow,...
              'Style','pushbutton',...
              'String','HardMode',...
              'Units','normalized',...
              'Position',[0.65,0.2,0.25,0.05],...
              'Callback',@HardModefcn);
    uicontrol('Parent',mainwindow,...
              'Style','pushbutton',...
              'String','CheckYourResult!',...
              'Units','normalized',...
              'Position',[0.1,0.12,0.25,0.05],...
              'Callback',@checkboardfcn);
    uicontrol('Parent',mainwindow,...
              'Style','pushbutton',...
              'String','ResetBoard',...
              'Units','normalized',...
              'Position',[0.375,0.12,0.25,0.05],...
              'Callback',@resetboardfcn);
    uicontrol('Parent',mainwindow,...
              'Style','pushbutton',...
              'String','SolveSudoku',...
              'Units','normalized',...
              'Position',[0.65,0.12,0.25,0.05],...
              'Callback',@solvesudokufcn);
    Greetingbox=uicontrol('Parent',mainwindow,...
                              'Style','text',...
                              'String','Greetings!Welcome to Sudoku.Have fun !:D',...
                              'Units','normalized',...
                              'Position',[0.05,0.025,0.9,0.07]);
%Declaring LocalFunction
    function board=readGUIboard2
        board=zeros(9);
        for i=1:9
        for j=1:9
            value=str2double(get(guiboard2(i,j),'String'));
            if isnan(value)
            board(i,j)=0;
            else
          board(i,j)=value;
            end
        end
        end
    end
  
    function display2GUIboard(board)
        for row=1:9
        for col=1:9
            if board(row,col)~=0
        set(guiboard2(row,col),'String',num2str(board(row,col)))
            else
        set(guiboard2(row,col),'String','')
            end
            set(guiboard2(row,col),'BackGroundColor','g')
        end
        end
    end
    

    function lockGUIboard(board)
        for row=1:9
        for col=1:9
            if board(row,col)==0
             set(guiboard2(row,col),'Enable','On')
            else
            set(guiboard2(row,col),'Enable','Off')
            end
        end
        end
    end
    
    function stat=checkboard(board)
        stat=false(9);
        %Check for violation
        for testvalue=1:9
            %Checking for violation in rows
            for row=1:9
                if sum(sum(board(row,:)==testvalue))>1
                 errorloc=(board(row,:)==testvalue);
                 stat(row,:)=stat(row,:)|errorloc;
                end
            end
            %Checking for violation in columns
            for col=1:9
                if sum(sum(board(:,col)==testvalue))>1
                    errorloc=(board(:,col)==testvalue);
                    stat(:,col)=stat(:,col)|errorloc;
                end
            end
            %Checking for violation in minigrid
            for gcrow=[1,2,3]
            for gccol=[1,2,3]
                if sum(sum(board(3*gcrow-2:3*gcrow,3*gccol-2:3*gccol)...
                           ==testvalue))>1
                    errorloc=(board(3*gcrow-2:3*gcrow,3*gccol-2:3*gccol)...
                              ==testvalue);
                    stat(3*gcrow-2:3*gcrow,3*gccol-2:3*gccol)=...
                          (stat(3*gcrow-2:3*gcrow,3*gccol-2:3*gccol)|...
                          errorloc);
                end
            end
            end
        end
    end
   
    function markGUIboard(stat)
        for row=1:9
        for col=1:9
            if stat(row,col)==1
                set(guiboard2(row,col),'BackGroundColor','r')
            else
                set(guiboard2(row,col),'BackGroundColor','y')
            end
        end
        end
    end
    %End of markGUIboard
    %Start of deleteGUIboard
    function board=deleteGUIboard(board,delcount)
        count=0;
        while count<delcount
            temp=ceil(rand*81);
            if board(temp)~=0
                board(temp)=0;
                count=count+1;
            end
        end
    end
    
%Declaring CallbackFunction
    function EasyModefcn(~,~)
        board=Solvesudoku;
        board=deleteGUIboard(board,20);
        display2GUIboard(board)
        lockGUIboard(board)
        set(Greetingbox,'String','Easy Sudoku Puzzle')
    end
 
  function NormalModefcn(~,~)
        board=Solvesudoku;
        board=deleteGUIboard(board,40);
        display2GUIboard(board)
        lockGUIboard(board)
        set(Greetingbox,'String','Normal Sudoku Puzzle')
    end
   
    function HardModefcn(~,~)
        board=Solvesudoku;
        board=deleteGUIboard(board,60);
        display2GUIboard(board)
        lockGUIboard(board)
        set(Greetingbox,'String','Hard Sudoku Puzzle')
    end
    
    function checkboardfcn(~,~)
       
        tempboard=readGUIboard2;
        stat=checkboard(tempboard);
        markGUIboard(stat)
        if sum(sum(stat))==0
            if sum(sum(tempboard==0))==0
                set(Greetingbox,'String','Puzzle Solved!Congratulaions')
            else
                set(Greetingbox,'String',...
                    'No Error detected!Vamos Vamos!!')
            end
        else
            set(Greetingbox,'String',...
                'Whoops!Error spotted :p')
        end
    end
    
    function resetboardfcn(~,~)
        board=zeros(9);
        display2GUIboard(board)
        lockGUIboard(board)
        set(Greetingbox,'String','Board reseted!')
    end
    function solvesudokufcn(~,~)
        tempboard=readGUIboard2;
        stat=checkboard(tempboard);
        if sum(sum(stat))==0
            result=Solvesudoku(tempboard);
            display2GUIboard(result)
            set(Greetingbox,'String','Puzzle Solved!Congrats!')
        else
            markGUIboard(stat)
            set(Greetingbox,'String',...
                'Puzzle cannot be solved due to error :(')
        end
    end
   
end
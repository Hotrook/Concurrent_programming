with Ada.Text_Io; use Ada.Text_Io;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

package body Types is


    function Minimum ( A, B: Integer) return Integer is
    begin
       if A <= B then
          return A;
       else
          return B;
       end if;
    end Minimum;

    procedure printFrost( toPrint : String; cond : Integer ) is
    begin
        if cond = 1 then
            Put_Line( toPrint );
        end if;
    end printFrost;

    procedure goTheLine( s1, LID, TID : in Integer; D : access Data) is
        speed : Integer;
        goTime : Integer;
    begin
        speed := Minimum( s1, D.lines( LID ).maxSpeed );
        goTime := D.lines( LID ).length / speed;
        printFrost( "Pociąg "& Integer'Image(TID) & " wjeżdża na tor "
                    & Integer'Image(Lid), D.t );
        delay Standard.Duration( (goTime + D.lines( LID ).minStop) *D.mult );
        printFrost( "Pociąg "& Integer'Image(TID) & " dojechał na koniec toru "
                    & Integer'Image(Lid), D.t );
    end goTheLine;

    procedure switchLine( V : access Switch ; mult,
                            SID, TID, LID, t: in Integer ) is
    begin
        printFrost( "Zwrotnica "& Integer'Image(SID) & " przekreca pociag "
                    & Integer'Image(TID) &" na tor "
                    & Integer'Image(LID), t );
        V.isOccupied := true;
        delay Standard.Duration(V.changeTime * mult);
        V.isOccupied := false;
    end;

    procedure takeTrain( V : access Line; numberTrain : in Integer ) is
    begin
        V.isOccupied := true;
        V.train := numberTrain;
    end;

    procedure addList( V : access Train; stationsList : in Int_array ) is
    begin
        V.stations := stationsList;
    end;

    task body TrainTask is
        nextState : Integer := 3;
        nextLine : Integer;
    begin
        accept Start do
            null;
        end Start;
        T.currentLine := D.edges( T.stations( 1 ) , T.stations( 2 ) );
        goTheLine( T.speed, T.currentLine, T.numberTrain, D);
        nextLine := D.edges(T.stations(T.currentState), T.stations( nextState ));
        B(T.stations(T.currentState)).Take( T.numberTrain, nextLine, 0 );
        loop
            select
                when True => accept StartStop do
                    T.isStop := True;
                end StartStop;
                delay Standard.Duration( D.lines(T.currentLine).minStop* D.mult );
            or
                when True => accept StartGo( LID : in Integer ) do
                    T.isStop := False;
                    D.lines( T.currentLine ).isOccupied := False;
                    T.currentLine := LID;
                end StartGo;
            end select;
            nextState := (nextState mod (T.stations'Length))+1;
            T.currentState := (T.currentState mod (T.stations'Length))+1;

            goTheLine( T.speed, nextLine, T.numberTrain, D);
            nextLine := D.edges(T.stations(T.currentState),
                        T.stations( nextState ));
            B(T.stations(T.currentState)).Take( T.numberTrain, nextLine, 0 );


        end loop;
    end TrainTask;

    task body Bufor is
        first : Integer := 0;
        size : Integer := 0;
        buf : array( 0..N ) of Tuple;
    begin
        loop
          select
            when size /= 0 =>
              accept Give (TID, LID, priority: out Integer) do
                TID := buf(first).TID;
                LID := buf(first).LID;
                priority := buf(first).priority;
                size := size - 1;
                first := (first + 1) mod N;
              end Give;
          or
            when size /= N =>
              accept Take (TID, LID, priority: in Integer) do
                buf((first+size) mod N).TID := TID;
                buf((first+size) mod N).LID := LID;
                buf((first+size) mod N).priority := priority;
                size := size + 1;
              end Take;
          end select;
        end loop;
    end Bufor;

    task body SwitchTask is
        id : Integer := N;
        TID, LID, priority : Integer;
    begin
        loop
            B.Give( TID, LID, priority );
            if D.lines( LID ).isOccupied = False then
                S.switchLine( D.mult, id, TID, LID, D.t );
                D.lines( LID ).isOccupied := True;
                TA(TID).StartGo( LID );
            elsif priority = 1 then
                while D.lines( LID ).isOccupied loop
                    null;
                end loop;
                S.switchLine( D.mult, id, TID, LID, D.t );
                D.lines( LID ).isOccupied := True;
                TA(TID).StartGo( LID );
            else
                B.Take( TID, LID, 1 );
            end if;
        end loop;
    end SwitchTask;

end Types;

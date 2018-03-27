-- Program, ktorym uruchamiane sa dwa zadania (+program glowny -wlasciwie trzy)
with Ada.Text_Io; use Ada.Text_Io;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Types; use Types;

procedure Z1ada is

    n, m, k, p, t : Integer;
    x, y, z, l : Integer;
    what, id : Integer;
    My_In_File : FILE_TYPE;
    timeLength, mult : Integer;
begin
    Get( n );
    Get( m );
    Get( k );
    Get( p );
    Get( t );

    declare
        D : aliased DataAccess := new Data( m, n );
        line : Integer;
        trains : TrainArray(1..p);
        switches : SwitchArray( 1..n ) := (others => new Switch);
        trainTasks : access TrainTaskArray := new  TrainTaskArray(1..p);
        buforTasks : access BuforPointerArray := new BuforPointerArray(1..n);
        switchTasks : SwitchTaskPointerArray(1..n);
    begin

        Open(My_In_File, In_File, "../config.txt");
        Get( My_In_File, timeLength);
        Get( My_In_File, mult);
        Close(My_In_File);
        D.t := t;
        D.mult := mult;
        for I in Integer range 1..n loop
            Get( x );
            switches( I ).changeTime := x;
            switches( I ).isOccupied := false;
            D.switches( I ).changeTime := x;
            D.switches( I ).isOccupied := false;
            buforTasks( I ) := new Bufor( I );
        end loop;
        for I in Integer range 1..m loop
            Get( x );
            Get( y );
            Get( l );
            Get( z );
            D.edges( x, y ) := I;
            D.lines( i ).length := l;
            D.lines( I ).maxSpeed := z;
            D.lines( I ).minStop := 0;
            D.lines( I ).isStop := False;
            D.lines( I ).isOccupied := False;
        end loop;
        for I in Integer range 1..k loop
            Get( x );
            Get( y );
            Get( z );
            line := D.edges( x, y );
            D.lines( line ).isStop := True;
            D.lines( line ).minStop := z;
        end loop;
        for I in Integer range 1..p loop
            Get( x );
            Get( y );
            Get( z );
            trains( I ) := new Train( z );
            trains( I ).numberTrain := I;
            trains( I ).numberPassengers := y;
            trains( I ).currentState := 2;
            trains( I ).speed := x;
            trains( I ).isStop := False;
            for J in Integer range 1..z loop
                Get( x );
                trains( I ).stations( J ) := x;
            end loop;
            trainTasks( I ) := new TrainTask( D, trains( I ), buforTasks );
            trainTasks( I ).Start;
        end loop;
        for I in Integer range 1..n loop
            switchTasks( I ) := new SwitchTask( I, buforTasks( I ),
                                                switches( I ), D,
                                                trainTasks);
        end loop;
        if D.t = 0 then
            loop
                Put_Line( "TANIEC");
                Get( what );
                Get( id );
                Put_Line( "TANIEC");
                Put( id );
                if what = 0 then
                    if trains( id ).isStop then
                        Put_Line( "Pociag " & Integer'Image(id)
                        & " jest na postoju na torze " &
                        Integer'Image(trains( id ).currentLine));
                    else
                        Put_Line( "Pociag " & Integer'Image(id) &
                        " jedzie torem "
                        & Integer'Image(trains( id ).currentLine));
                    end if;
                elsif what = 1 then
                    if D.lines( id ).isOccupied then
                        Put_Line( "Linia " & Integer'Image(id) &
                        " jest zajeta przez pociag");
                    else
                        Put_Line( "Linia " & Integer'Image(id) &
                        " jest wolna");
                    end if;
                elsif what = 2 then
                    if D.switches( id ).isOccupied then
                        Put_Line( "Zwrotnica " & Integer'Image(id) &
                        " jest zajeta przez pociag");
                    else
                        Put_Line( "Zwrotnica " & Integer'Image(id) &
                        " jest wolna");
                    end if;
                end if;
            end loop;
        end if;
    end;
end Z1ada;

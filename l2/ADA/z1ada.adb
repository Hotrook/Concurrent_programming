-- Program, ktorym uruchamiane sa dwa zadania (+program glowny -wlasciwie trzy)
with Ada.Text_Io; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

with Types;             use Types;
with SwitchTaskClass;   use SwitchTaskClass;
with LineClass;         use LineClass;
with DataClass;         use DataClass;
with Buffor;            use Buffor;
with LineClass;         use LineClass;
with Functions;         use Functions;
with ReadFunctions;     use ReadFunctions;

procedure Z1ada is
    n, m, k, p, t : Integer;
    start, constCrewTime : Integer;

    what, id : Integer;
begin
    Get( n );
    Get( m );
    Get( k );
    Get( p );
    Get( t );

    declare
        D : DataAccess := new Data( n, m+k );
        trains :  access TrainArray := new TrainArray(1..p);
        r : access Retrier;
    begin
        D.switchTasks := new SwitchTaskArray(1..n);
        D.trainTasks := new TrainTaskArray(1..p);
        D.lines := new Line_Array(1..(m+k));
        D.trains := new TrainArray( 1..p) ;
        D.r := new RetrierArray( 1..p) ;

        getConfigurationFromFile( D );
        D.t := t;


        readSwitches( D, n );
        readGoLines( D, m );
        readStopLines( D, m, k );
        readTrains( D, p );
        Get( start );
        Get( constCrewTime );
        D.CC := new ConstructionCrew( start, constCrewTime, D );
        D.CCT := new CCTask( D.CC, D );


        for I in Integer range 1..p loop
            D.r( I ) := new Retrier( D );
            D.r( I ).start;
        end loop;

        for I in Integer range 1..p loop
            D.trainTasks( I ) := new TrainTask( D, D.trains( I ) );
            D.trainTasks( I ).Start;
        end loop;

        for I in Integer range 1..n loop
            D.switchTasks( I ) := new SwitchTask( I,  D.switches( I ), D );
        end loop;

        D.CCT.START;

        D.breakdownGenerator := new BG( D, p, m+k, n );

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

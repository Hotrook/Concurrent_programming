


package body ReadFunctions is



    procedure getConfigurationFromFile( D : access DataClass.Data ) is
        My_In_File : FILE_TYPE;
        timeLength : Integer;
        mult : Integer;
    begin
        Open(My_In_File, In_File, "../config.txt");
        Get( My_In_File, timeLength);
        Get( My_In_File, mult);
        Close(My_In_File);
        D.t := timeLength;
        D.mult := mult;
    end getConfigurationFromFile;





    procedure readSwitches( D : access DataClass.Data;
                            n : Integer ) is
        x : Integer;
    begin
        D.switches := new SwitchArray( 1..n );
        for I in integer range 1..n loop
            for J in Integer range 1..n loop
                D.edges( I, J ) := 0;
            end loop;
        end loop;
        for I in Integer range 1..n loop
            Get( x );
            D.switches( I ) := new Switch( D, I );
            D.switches( I ).changeTime := x;
            D.switches( I ).isOccupied := False;
            D.switches( I ).isBroken := False;
        end loop;
    end readSwitches;




    procedure readGoLines( D : access DataClass.Data; m : Integer ) is
        x : Integer;
        y : Integer;
        l : Integer;
        z : Integer;
    begin
        for I in Integer range 1..m loop
            Get( x );
            Get( y );
            Get( l );
            Get( z );
            --Put( x );
            --Put( y );
            --Put( l );
            --Put( z );
            D.edges( x, y ) := I;
            D.lines( I ) := new LineClass.Line( I );
            --D.lines( I ).id := I;
            D.lines( I ).first := x;
            D.lines( I ).second := y;
            D.lines( I ).length := l;
            D.lines( I ).maxSpeed := z;
            D.lines( I ).minStop := 0;
            D.lines( I ).isStopLine := False;
            D.lines( I ).isOccupied := False;
            D.lines( I ).isBroken := False;
        end loop;
    end readGoLines;



    procedure readStopLines( D : access DataClass.Data; m, k : Integer ) is
        x : Integer;
        y : Integer;
        l : Integer;
        z : Integer;
    begin
    for I in Integer range (m+1)..(m+k) loop
        Get( x );
        Get( y );
        Get( l );
        Get( z );
        D.edges( x, y ) := I;
        D.lines( I ) := new LineClass.Line( I );
        D.lines( I ).first := x;
        D.lines( I ).second := y;
        D.lines( I ).length := 0;
        D.lines( I ).maxSpeed := 0;
        D.lines( I ).minStop := l;
        D.lines( I ).capacity := z;
        D.lines( I ).occupied := 0;
        D.lines( I ).isStopLine := True;
        D.lines( I ).isOccupied := False;
        D.lines( I ).isBroken := False;
    end loop;
    end readStopLines;



    procedure readTrains( D : access DataClass.Data;
                          p : Integer) is
        x : Integer;
        y : Integer;
        z : Integer;
    begin
        for I in Integer range 1..p loop
            Get( x );
            Get( y );
            Get( z );
            D.trains( I ) := new Train( z, D );
            D.trains( I ).numberTrain := I;
            D.trains( I ).numberPassengers := y;
            D.trains( I ).currentState := 2;
            D.trains( I ).speed := x;
            D.trains( I ).isStop := False;
            D.trains( I ).isBroken := False;
            D.trains( I ).isWait := False;
            for J in Integer range 1..z loop
                Get( x );
                D.trains( I ).stations( J ) := x;
            end loop;
        end loop;
    end readTrains;




    procedure readWorkers( D : access DataClass.Data;
                        w : Integer ) is
        temp : access Worker;
        x : Integer;
    begin

        for I in Integer range 1..w loop

            get( x );
            temp := new Worker( D, I, x );
            D.workers( I ) := new WorkerTask( temp );
        end loop;
    end readWorkers;



end ReadFunctions;

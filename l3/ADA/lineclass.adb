


package body LineClass is



    procedure takeTrain( V : access Line; numberTrain : in Integer ) is
    begin
        V.isOccupied := true;
        V.train := numberTrain;
    end;

    procedure dosth( V : access Line; numberTrain : in Integer ) is
    begin
        V.train := numberTrain;
    end;

    function checkIfOccupied( L : access Line ) return Boolean is
    begin
        --Put_Line("Linia  sprawdzana jest ta " & Integer'Image( L.id ) );
        if L.isStopLine then
            if L.occupied = L.capacity then
                return True;
            else
                return False;
            end if;
        else
            return L.isOccupied;
        end if;
    end checkIfOccupied;



    procedure releaseLine( L : access Line ) is
    begin
        if L.isStopLine then
            L.occupied := Integer'Max( L.occupied - 1, 0 );
        end if;
        L.isOccupied := False;
    end releaseLine;



    procedure reserveLine( L : access Line ) is
    begin
        if L.isStopLine then
            L.occupied := Integer'MIN( L.occupied +1 , L.capacity );
            if L.occupied = L.capacity then
                L.isOccupied := True;
            end if;
        else
            L.isOccupied := True;
        end if;
    end reserveLine;
end LineClass;

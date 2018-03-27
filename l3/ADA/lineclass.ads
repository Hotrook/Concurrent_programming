with Ada.Unchecked_Deallocation; --pokiet potrzebny do zadeklarowani procedury zwalniajacej pamiec
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Text_IO; use Ada.Text_IO;




package LineClass is



    type Line( I : Integer ) is tagged record
        id : Integer := I;
        first : Integer;
        second : Integer;
        length : Integer;
        maxSpeed : Integer;
        minStop : Integer;
        capacity : Integer;
        occupied : Integer;
        train : Integer;
        isStopLine : Boolean;
        isOccupied : Boolean;
        isBroken : Boolean;
    end record;




    type Line_Array is array( Positive range <> ) of access Line;




    procedure takeTrain( V : access Line; numberTrain : in Integer );
    procedure dosth( V : access Line; numberTrain : in Integer );
    procedure releaseLine( L : access Line );
    procedure reserveLine( L : access Line );
    function checkIfOccupied( L : access Line ) return Boolean;



end LineClass;

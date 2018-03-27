with Ada.Unchecked_Deallocation; --pokiet potrzebny do zadeklarowani procedury zwalniajacej pamiec
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

package Types is

    type Int_Array is array (Positive range <>) of Integer;
    type Int_Array2 is array( Positive range <>, Positive range <>) of Integer;
    type IntPointer is access Integer;
    type IntPointerArray is array( Positive range <> ) of IntPointer;

    type Tuple is record
        TID, LID, priority: integer;
    end record;

    type Line is tagged record
        length, maxSpeed, minStop, train : Integer;
        isStop, isOccupied : Boolean;
    end record;

    type Switch is tagged record
    	changeTime : Integer;
    	isOccupied : Boolean;
    end record;

    type Train(ilength: Natural) is tagged record
    	numberTrain, numberPassengers, speed,
        currentLine, currentState : Integer;
    	isStop : Boolean;
        stations : Int_Array(1..ilength);
        --stations []int
    end record;

    type TrainPointer is access Train;
    type TrainArray is array( Positive range <> ) of TrainPointer;
    type Line_Array is array( Positive range <> ) of Line;
    type Switch_Array is array( Positive range <> ) of Switch;
    type SwitchPointer is access Switch;
    type SwitchArray is array( Positive range <> ) of SwitchPointer;

    type Data(linesNr, switchesNr : Natural) is tagged record
        lNr : Integer := linesNr;
        sNr : Integer := switchesNr;
        lines :   Line_Array(1..linesNr);
        switches :  Switch_Array(1..switchesNr);
        edges :  Int_array2(1..switchesNr, 1..switchesNr);
        t : Integer;
        mult : Integer;
    end record;
    type DataAccess is access Data;


    task type Bufor( N : Integer ) is
        entry Take( TID, LID, priority : in Integer);
        entry Give( TID, LID, priority : out Integer);
    end Bufor;

    type BuforPointer is access Bufor;
    type BuforPointerArray is array( Positive range <>) of BuforPointer;


    task type TrainTask(
                         D : access Data;
                         T : access Train;
                         B : access BuforPointerArray
                         ) is
        entry Start;
        entry StartStop;
        entry StartGo( LID : in Integer );
    end TrainTask;

    type TrainTaskPointer is access TrainTask;
    type TrainTaskArray is array (Positive range <>) of TrainTaskPointer;


    task type SwitchTask( N : Integer;
                          B : access Bufor;
                          S : access Switch;
                          D : access Data;
                          TA : access TrainTaskArray
                          ) is
    end SwitchTask;

    type SwitchTaskPointer is access SwitchTask;
    type SwitchTaskPointerArray is array( Positive range <> ) of SwitchTaskPointer;


    procedure switchLine( V : access Switch ; mult, SID, TID, LID, t : in Integer );
    procedure takeTrain( V : access Line; numberTrain : in Integer );
    procedure addList( V : access Train; stationsList : in Int_Array);
    procedure goTheLine( s1, LID, TID : in Integer; D : access Data);
    procedure printFrost( toPrint : String; cond : Integer );
    function Minimum( A, B : Integer ) return Integer;
end Types;

with Ada.Unchecked_Deallocation; --pokiet potrzebny do zadeklarowani procedury zwalniajacej pamiec
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Text_IO; use Ada.Text_IO;

with QueueClass;        use QueueClass;
with Buffor;            use Buffor;
with DataClass;         use DataClass;
with Types;             use Types;
with Functions;         use Functions;
with LineClass;             use LineClass;

package SwitchTaskClass is

    type Switch;
    type SwitchPointer is access Switch;

    task type SwitchTask( N : Integer;
                          S : SwitchPointer;
                          D : access Data ) is
        entry SWITCH_LINE( TID, LID, priority : in Integer);
        entry SWITCH_LINE_WITH_WAIT( TID, LID, priority : in Integer);
        entry SWITCH_CCT( NEXT, CURR : in Integer );
    end SwitchTask;


    type SwitchTaskPointer is access SwitchTask;
    type SwitchTaskArray is array( Positive range <> ) of access SwitchTask;





    type Switch(  D : access DataClass.Data;
                  id : Integer ) is tagged record
        changeTime : Integer;
        trainId : Integer;
        isOccupied : Boolean;
        isBroken : Boolean;
    end record;

    --type Switch_Array is array( Positive range <> ) of Switch;
    --type SwitchPointer is access Switch;
    type SwitchArray is array( Positive range <> ) of SwitchPointer;


    procedure switchLine( S : access Switch ; TID, LID : Integer );
    procedure releaseLine( S : access Switch ; LID : Integer );
    procedure printStartInfo( S : access Switch; TID, LID : Integer );
    procedure printFinishInfo( S : access Switch; TID, LID : Integer );
    procedure switchConstCrew( S : access Switch; lineId : Integer );
    function handleSpecOrder( S: access Switch; lineId, help : Integer )return Integer;





    task type Retrier( D : access Data ) is
        entry START;
        entry RETRY( TID : in Integer );
        entry GO( TID : in Integer );
    end Retrier;

    type RetrierArray is array( Natural range <> ) of access Retrier;





    type Train(ilength: Natural ; D : access Data ) is tagged record
        numberTrain : Integer;
        numberPassengers : Integer;
        speed : Integer;
        nextLine : Integer;
        currentLine : Integer;
        currentState : Integer;
        isStop : Boolean;
        uncondStop : Boolean;
        isBroken : Boolean;
        isWait : Boolean;
        stations : Int_Array(1..ilength);
        --stations []int
    end record;

    type TrainArray is array( Natural range <> ) of access Train;

    task type TrainTask(
                         D : DataAccess;
                         T : access Train ) is
        entry Start;
        entry GO;
        entry RETRY;
        entry stopChan;
    end TrainTask;

    type TrainTaskPointer is access TrainTask;
    type TrainTaskArray is array (Positive range <>) of TrainTaskPointer;


    procedure addList( V : access Train; stationsList : in Int_Array);
    procedure goCurrentLine( T : access Train );
    procedure printStopInfo( T : access Train  );
    procedure printStartGoingInfo( T : access Train );
    procedure printStopGoingInfo( T : access Train );

    procedure calculateNextLine( T : access Train);
    procedure changeLine( T : access Train  );
    procedure changeLineWithWait( T : access Train );
    procedure checkIfBroken( T : access Train );
    procedure stopAndWaitIfBreakdown( T : access Train; msg : Integer);





    task type BG( D : access Data; trains, lines, switches : Integer ) is
        entry CONTINUE;
    end BG;





    type ConstructionCrew( s, r : Integer; D : access DataClass.Data )is tagged record
        id : Integer;
        repairTime : Integer := r;
        origin : Integer := s;
        typeOfBroken : BREAK_TYPE;
        startSwitch : Integer;
        graph : access Int_Array2;
        path : access Int_Array;
    end record;


    task type CCTask( CC : access ConstructionCrew;
                       D : access DataClass.Data ) is
        entry BREAKDOWN( t : BREAK_TYPE; id : in Integer );
        entry START;
        entry CONFIRMATION( id : Integer );
        entry GO;
        entry RETRY;
    end CCTask;

    procedure sendBreak( C : access ConstructionCrew );
    procedure sendStopQueries( C : access ConstructionCrew );
    procedure createGraph( C : access ConstructionCrew );
    function BFS( C : access ConstructionCrew; start, stop : Integer )
        return Boolean;
    procedure createPath( C : access ConstructionCrew;
                          start, stop : Integer );
    procedure blockAllSwitchesOnThePath(C : access ConstructionCrew);
    procedure unblockAllSwitchesOnThePath(C : access ConstructionCrew);
    procedure restoreTraffic( C : access ConstructionCrew );
    procedure stats( C : access ConstructionCrew );
    procedure goByPath( C : access ConstructionCrew );
    procedure changeLine( C : access ConstructionCrew ; pos : Integer );
    procedure useSwitch( C : access ConstructionCrew ; switchId, lineId : Integer );
    procedure printStartSwitchInfo( C : access ConstructionCrew ; switchId : Integer );
    procedure printStopSwitchInfo( C : access ConstructionCrew ; lineId : Integer );
    procedure goCurrentLine( C : access ConstructionCrew ; pos : Integer );
    procedure useLine( C : access ConstructionCrew ; lineId : Integer );
    procedure printStartLineInfo( C : access ConstructionCrew ; lineId : Integer );
    procedure printStopLineInfo( C : access ConstructionCrew ; lineId : Integer );
    procedure printPointReachInfo( C : access ConstructionCrew );
    procedure repair( C : access ConstructionCrew );
    procedure goBack( C : access ConstructionCrew );
    procedure printFinishBreakdownInfo( C : access ConstructionCrew );
    procedure printHomeInfo( C : access ConstructionCrew );
    procedure printBreakdownInfo( C : access ConstructionCrew );

end SwitchTaskClass;

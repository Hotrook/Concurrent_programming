with Ada.Unchecked_Deallocation; --pokiet potrzebny do zadeklarowani procedury zwalniajacej pamiec
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

with LineClass;             use LineClass;
limited with SwitchTaskClass;
with Types;                 use Types;
with Functions;             use Functions;

package DataClass is



    type Data(n, linesNumber : Natural) is tagged record
        lNr : Integer := linesNumber;
        sNr : Integer := n;
        lines               : access Line_Array;
        switchTasks         : access SwitchTaskClass.SwitchTaskArray;
        switches            : access SwitchTaskClass.SwitchArray;
        trains              : access SwitchTaskClass.TrainArray;
        trainTasks          : access SwitchTaskClass.TrainTaskArray;
        CCT                 : access SwitchTaskClass.CCTask;
        CC                  : access SwitchTaskClass.ConstructionCrew;
        workers             : access SwitchTaskClass.WorkerArray;
        workersManager      : access SwitchTaskClass.WorkerManagerTask;
        wm                  : access SwitchTaskClass.WorkerManager;
        breakdownGenerator  : access SwitchTaskClass.BG;
        edges               : Int_Array2(1..n, 1..n);
        r                   : access SwitchTaskClass.RetrierArray;
        t                   : Integer;
        mult                : Integer;
    end record;

    type DataAccess is access all Data;



    procedure goTheLine( s1, LID, TID : in Integer; D : access Data);





end DataClass;

with Ada.Unchecked_Deallocation; --pokiet potrzebny do zadeklarowani procedury zwalniajacej pamiec
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

with DataClass;
with SwitchTaskClass; use SwitchTaskClass;
with Buffor; use Buffor;
with LineClass; use LineClass;

package ReadFunctions is


    procedure getConfigurationFromFile( D : access DataClass.Data );
    procedure readSwitches( D : access DataClass.Data;
                            n : Integer );
    procedure readGoLines( D : access DataClass.Data; m : Integer );
    procedure readStopLines( D : access DataClass.Data; m, k : Integer );
    procedure readTrains( D : access DataClass.Data;
                          p : Integer );
end ReadFunctions;

limited with SwitchClass;
limited with TrainClass;

package Arrays is

    type SwitchArray is array( Positive range <> ) of access SwitchTask;
    type TrainArray is array( Positive range <> ) of access TrainTask;

end Arrays;

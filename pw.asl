/* Project Wingman Autosplitter
 * Created by FalconLuma (FalconLuma#3614 on Discord)
 *
 * Works with Project Wingman V1.0.4D
 */

state("ProjectWingman-Win64-Shipping")
{
// Counts the number of times modules have been loaded
    // Each transistion will increse this by one
    int moduleCount: "TrueSkyPluginRender_MT.dll", 0x00F14FF0, 0x88, 0x20, 0xA04;

// Current points
    //  - Always resets when on retry
    //  - Resets after debreif in campaign
    //  - Resets after selecting a mission in free mission menu
    int points: 0x06C8DA58, 0x8, 0x420;

// Controls the appearance of the 'Mission Complete/Over' text
    //  2 = Mission Active 
    //  3 = Mission Complete/Over
    int missionComplete: 0x06C70B88, 0x3E8, 0x58, 0x6D8; // Does not change in M21-Kings

// The current state of the game
    //  0 = Loading
    //  1 = Running (After going back to hangar once, this only represents in mission)
    //  2 = Menu (After going back to hangar once)
    // Exceptions: 
    //  M8, M10 - Loading = 1, Running = 2 
    int screenMode: 0x06C91158, 0x158 , 0x5C;

// Whether the game is puased
    //  0 = Running
    //  1 = Paused
    int isPaused: 0x06BACC38, 0x560;

// The current difficulty setting
    //  0 = Easy
    //  1 = Medium
    //  2 = Hard
    //  3 = Mercenary
    int difficulty: 0x06C64038, 0x4E8, 0x2E0;

// Uses multiples of 256 to track certain modifiers, values are added when multiple modifiers are active
    //  1 = Glass Cannon
    //  256 = Budget Cuts
    //  65536 = Gun Runner
    //  16777216 = Camouflage
    int modifiers1: 0x06C8DA58, 0x8, 0xA40;
    //  1 = N/A
    //  256 = N/A
    //  65536 = N/A
    //  16777216 = Cordium Interference
    int modifiers2: 0x06C8DA58, 0x8, 0xA48;
    //  1 = N/A
    //  256 = Ace Training
    //  65536 = N/A
    //  16777216 = Double Time
    int modifiers3: 0x06C8DA58, 0x8, 0xA48;
    //  1 = N/A
    //  256 = Botched Requisition
    //  65536 = N/A
    //  16777216 = Speed Demon
    int modifiers4: 0x06C8DA58, 0x8, 0xA48;   
}

startup
{
    settings.Add("ILMode",false,"Individual Level Mode");
    settings.SetToolTip("ILMode", "Only use for ILs. Timer will automaticaly start and will reset after each level");
    //settings.Add("loadless",false,"Load Removal");
    //settings.SetToolTip("loadless","Pause the timer whenever the game is loadng");
    vars.prevScore = 0; // Stores the score of the previous mission, used for M21 split logic
    vars.timerStart = 0;
    vars.oldTimerStart = 0;  
    vars.pause = true;
}

update
{
    if(current.screenMode != old.screenMode){
        vars.pause = false; 
    }
    
}

start
{
    // Inconsistent screenMode sometimes, probably remove this

    // Prevent timer starting when the game first opens
    /*
    if(current.moduleCount > 3 && settings["ILMode"]) {
        if(current.isPaused == 0 && current.screenMode == 1 && old.screenMode == 0 && current.moduleCount == old.moduleCount) {
            return true;
        }
    } 
    */    
}

isLoading
{
    /*
    if(!settings["ILMode"]){
        return vars.pause;
    } else{
        return false;
    }
    */
    
}

split
{
    // When mission complete changes 2 -> 3
    if(current.missionComplete > old.missionComplete){
        vars.prevScore = current.points;
        return true;
    }

    // M21-Kings Split Logic 
    /* Possible Scores
     * Norm   : 12000
     * Merc   : 13000
     * NormDT : 24000
     * MercDT : 26000
     */

    // If the next module is loading and points count equals one of the possible counts for M21
    if((current.points == 12000 || current.points == 13000 || current.points == 24000 || current.points == 26000) && 
        current.moduleCount > old.moduleCount) {
        // Always split for ILs
        if(settings["ILMode"]) {
            return true;
        // Only split in campaign if the score on the previous mission was greter than minimum score for M20-Presidia
        } else if(vars.prevScore >= 20950) {
            return true;
        }
    }
}

reset
{
    // Only reset in IL Mode
    if(settings["ILMode"]){
        // Resets when going back to the press start screen
        if(current.screenMode == 0 && old.screenMode == 2){
            vars.oldTimerStart = vars.timerStart;
            return true;
        }
    }
}


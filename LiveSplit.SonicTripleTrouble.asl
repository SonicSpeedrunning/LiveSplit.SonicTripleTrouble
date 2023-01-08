// Sonic Triple Trouble - Game Gear
// Autosplitter
// Coding: Jujstme

// This script serves as a sample script for use with emu-help

// We will use LiveSplit itself as a state descriptor
// The emu-help will internally look for the emulators it supports
// --> Tip: if emu-help gets updated with support for new emulators, you won't need to update the script.
state("LiveSplit") {}

startup
{
    // Creates a persistent instance of the SMS class
    vars.Helper = Assembly.Load(File.ReadAllBytes("Components/emu-help")).CreateInstance("SMS");

    // Define a new MemoryWatcherList with the addresses we need in our autosplitter.
    // All addresses are relative offsets to the base WRAM address, which is picked up
    // automatically by the helper.
    // Offsets can be found with tools like the RAM watcher in BizHawk.
    vars.Helper.Load = (Func<IntPtr, MemoryWatcherList>)(WRAM => new MemoryWatcherList
    {
        new MemoryWatcher<byte>(WRAM + 0x1145) { Name = "ZoneID" },
        new MemoryWatcher<byte>(WRAM + 0x1147) { Name = "ActID" },
        new MemoryWatcher<byte>(WRAM + 0x1FED) { Name = "StartTrigger" },
        new MemoryWatcher<byte>(WRAM + 0x1C49) { Name = "LastSplit" },
    });

    string[,] Settings =
    {
        { "0", "Great Turquoise - Act 1", null },
        { "1", "Great Turquoise - Act 2", null },
        { "2", "Great Turquoise - Act 3", null },
        { "3", "Sunset Park - Act 1", null },
        { "4", "Sunset Park - Act 2", null },
        { "5", "Sunset Park - Act 3", null },
        { "6", "Meta Junglira - Act 1", null },
        { "7", "Meta Junglira - Act 2", null },
        { "8", "Meta Junglira - Act 3", null },
        { "9", "Robotnik Winter - Act 1", null },
        { "10", "Robotnik Winter - Act 2", null },
        { "11", "Robotnik Winter - Act 3", null },
        { "12", "Tidal Plant - Act 1", null },
        { "13", "Tidal Plant - Act 2", null },
        { "14", "Tidal Plant - Act 3", null },
        { "15", "Atomic Destroyer - Act 1", null },
        { "16", "Atomic Destroyer - Act 2", null },
        { "17", "Atomic Destroyer - Act 3", null },
    };
    for (int i = 0; i < Settings.GetLength(0); i++) settings.Add(Settings[i, 0], true, Settings[i, 1], Settings[i, 2]);
}

init
{
    // Default values
    current.Act = 0;
}

update
{
    // This line is required to run the main loop inside the helper
    if (!vars.Helper.Update())
        return false;

    var tempAct = vars.Helper["ZoneID"].Current > 5 || vars.Helper["ActID"].Current > 2 ? -1 : vars.Helper["ZoneID"].Current * 3 + vars.Helper["ActID"].Current;
    current.Act = tempAct == -1 ? old.Act : tempAct;
}

start
{
    return current.Act == 0 && vars.Helper["StartTrigger"].Old == 8 && vars.Helper["StartTrigger"].Current == 0;
}

split
{
    if (current.Act == 17)
        return settings["17"] && vars.Helper["LastSplit"].Current == 0xFF && vars.Helper["LastSplit"].Old == 0x0;
    else if (current.Act == old.Act + 1)
        return settings[old.Act.ToString()];
}

shutdown
{
    // Terminates the main Task being run inside the helper
    // Please don't remove this line from this block
    vars.Helper.Dispose();
}
using BepInEx;
using System;
using System.Linq;
using Utilla.Models;

namespace Utilla
{
    public class PluginInfo
    {
        public BaseUnityPlugin Plugin { get; set; }
        public Gamemode[] Gamemodes { get; set; }
        public Action<string> OnGamemodeJoin { get; set; }
        public Action<string> OnGamemodeLeave { get; set; }

        public override string ToString()
        {
            string pluginName = Plugin?.Info?.Metadata.Name ?? "(unknown plugin)";
            return $"{pluginName} [{string.Join(", ", Gamemodes?.Select(x => x.DisplayName) ?? Enumerable.Empty<string>())}]";
        }
    }
}

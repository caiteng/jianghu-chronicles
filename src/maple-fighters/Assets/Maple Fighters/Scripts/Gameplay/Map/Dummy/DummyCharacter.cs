using System;
using Scripts.Gameplay.Player;

namespace Scripts.Gameplay.Map.Dummy
{
    [Serializable]
    public class DummyCharacter
    {
        public DummyEntity DummyEntity;

        public string CharacterName = "江湖少侠";

        public CharacterClasses CharacterClass;
    }
}

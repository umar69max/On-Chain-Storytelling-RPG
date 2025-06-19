// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title On-Chain Storytelling RPG
/// @notice A simplified RPG where players can create characters, embark on quests, and influence story outcomes on-chain.
contract Project {

    struct Character {
        string name;
        uint level;
        uint experience;
        uint lastQuestTimestamp;
    }

    mapping(address => Character) public characters;
    mapping(uint => string) public storyEvents; // eventId => event description
    uint public nextEventId;

    event CharacterCreated(address indexed player, string name);
    event QuestCompleted(address indexed player, uint xpGained, string storyOutcome);
    event StoryEventAdded(uint eventId, string description);

    /// @notice Create a new character for the sender
    /// @param _name Name of the character
    function createCharacter(string calldata _name) external {
        require(bytes(characters[msg.sender].name).length == 0, "Character already exists");
        characters[msg.sender] = Character(_name, 1, 0, 0);
        emit CharacterCreated(msg.sender, _name);
    }

    /// @notice Embark on a quest, gain experience, and influence the story
    /// @param _xp Experience gained from the quest
    /// @param _storyOutcome Description of the story outcome influenced by the quest
    function completeQuest(uint _xp, string calldata _storyOutcome) external {
        Character storage char = characters[msg.sender];
        require(bytes(char.name).length != 0, "Create character first");

        // Simple cooldown: 1 quest per day
        require(block.timestamp > char.lastQuestTimestamp + 1 days, "Quest cooldown active");

        char.experience += _xp;
        char.lastQuestTimestamp = block.timestamp;

        // Level up if experience passes threshold (e.g., 100 xp per level)
        if(char.experience >= char.level * 100) {
            char.level += 1;
            char.experience = 0;
        }

        // Add the story event to global events
        storyEvents[nextEventId] = _storyOutcome;
        emit StoryEventAdded(nextEventId, _storyOutcome);
        nextEventId++;

        emit QuestCompleted(msg.sender, _xp, _storyOutcome);
    }

    /// @notice Get character details of a player
    /// @param _player Address of the player
    /// @return name, level, experience, lastQuestTimestamp
    function getCharacter(address _player) external view returns (string memory, uint, uint, uint) {
        Character storage char = characters[_player];
        return (char.name, char.level, char.experience, char.lastQuestTimestamp);
    }
}

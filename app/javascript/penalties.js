window.updateFplteamId = function() {
  const fplteamDiscordNameInput = document.getElementById('fplteam_discord_name');
  const fplteamIdInput = document.getElementById('fplteam_id');
  const fplteamOption = document.querySelector(`option[value="${fplteamDiscordNameInput.value}"]`);

  if (fplteamOption) {
    fplteamIdInput.value = fplteamOption.dataset.value;
  } else {
    fplteamIdInput.value = '';
  }
}

window.updatePlayerId = function() {
  const playerWebNameInput = document.getElementById('player_web_name');
  const playerIdInput = document.getElementById('player_id');
  const playerOption = document.querySelector(`option[value="${playerWebNameInput.value}"]`);

  if (playerOption) {
    playerIdInput.value = playerOption.dataset.value;
  } else {
    playerIdInput.value = '';
  }
}

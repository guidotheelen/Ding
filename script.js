// State
let state = {
  prepDuration: 10, // seconds
  roundDuration: 180, // seconds
  restDuration: 60, // seconds
  totalRounds: 8,
  currentRound: 1,
  timeLeft: 180,
  phase: "READY", // READY, PREP, ROUND, REST, DONE
  isRunning: false,
  soundEnabled: true,
};

let timerInterval = null;
let audioContext = null;

// DOM Elements
const els = {
  minutes: document.getElementById("minutes-display"),
  seconds: document.getElementById("seconds-display"),
  currentRound: document.getElementById("current-round-display"),
  status: document.getElementById("status-text"),
  subStatus: document.getElementById("sub-status-text"),
  progressBar: document.getElementById("progress-bar"),
  progressText: document.getElementById("progress-text"),
  playBtn: document.getElementById("play-btn"),
  playIcon: document.getElementById("play-icon"),
  resetBtn: document.getElementById("reset-btn"),
  muteBtn: document.getElementById("mute-btn"),
  muteIcon: document.getElementById("mute-icon"),
  prepInput: document.getElementById("prep-duration"),
  roundInput: document.getElementById("round-duration"),
  restInput: document.getElementById("rest-duration"),
  roundsInput: document.getElementById("total-rounds"),
  soundToggle: document.getElementById("toggle"),
  mobileMenuBtn: document.getElementById("mobile-menu-btn"),
  sidebar: document.getElementById("settings-sidebar"),
  menuBackdrop: document.getElementById("menu-backdrop"),
};

// Sounds
const sounds = {
  ding: new Audio("sounds/ding.mp3"),
  endBell: new Audio("sounds/end_bell.mp3"),
  beep: new Audio("sounds/beep.mp3"),
};

// Initialize
function init() {
  // Sync input values with state
  els.roundsInput.value = state.totalRounds;
  els.prepInput.value = formatDuration(state.prepDuration);
  els.roundInput.value = formatDuration(state.roundDuration);
  els.restInput.value = formatDuration(state.restDuration);

  updateDisplay();

  // Event Listeners
  els.playBtn.addEventListener("click", toggleTimer);
  els.resetBtn.addEventListener("click", resetTimer);
  els.muteBtn.addEventListener("click", toggleSound);
  els.soundToggle.addEventListener("change", (e) => {
    state.soundEnabled = e.target.checked;
    updateSoundIcon();
  });

  if (els.mobileMenuBtn) {
    els.mobileMenuBtn.addEventListener("click", toggleMobileMenu);
  }

  els.roundsInput.addEventListener("change", (e) => {
    if (state.isRunning) {
      e.target.value = state.totalRounds;
      return;
    }
    let val = Number.parseInt(e.target.value);
    if (Number.isNaN(val) || val < 1) val = 1;
    if (val > 50) val = 50;
    state.totalRounds = val;
    e.target.value = val;
    if (state.phase === "READY") updateDisplay();
  });
}

// Timer Logic
function toggleTimer() {
  if (state.isRunning) {
    pauseTimer();
  } else {
    startTimer();
  }
}

function startTimer() {
  if (state.phase === "DONE") resetTimer();

  state.isRunning = true;
  els.playIcon.textContent = "pause";
  els.playBtn.classList.remove("bg-primary", "hover:bg-[#ff3b44]");
  els.playBtn.classList.add("bg-[#ee2b34]", "hover:bg-[#d4252d]"); // Keep red but maybe darker? Or just keep same.

  // If starting from READY, go to PREP
  if (state.phase === "READY") {
    if (state.prepDuration > 0) {
      state.phase = "PREP";
      state.timeLeft = state.prepDuration;
    } else {
      state.phase = "ROUND";
      playSound("ding");
    }
  }

  timerInterval = setInterval(tick, 1000);
}

function pauseTimer() {
  state.isRunning = false;
  els.playIcon.textContent = "play_arrow";
  clearInterval(timerInterval);
}

function resetTimer() {
  pauseTimer();
  state.phase = "READY";
  state.currentRound = 1;
  state.timeLeft = state.roundDuration;
  updateDisplay();
}

function tick() {
  state.timeLeft--;

  // Warning sounds - beep every second from 10 down to 1
  if (state.timeLeft <= 10 && state.timeLeft > 0 && state.phase === "ROUND") {
    playSound("beep");
  }
  // Prep warning (3, 2, 1)
  if (state.phase === "PREP" && state.timeLeft <= 3 && state.timeLeft > 0) {
    playSound("beep");
  }

  updateDisplay();

  // Phase transition after displaying 00:00
  if (state.timeLeft <= 0) {
    handlePhaseTransition();
  }
}

function handlePhaseTransition() {
  if (state.phase === "PREP") {
    state.phase = "ROUND";
    state.timeLeft = state.roundDuration;
    playSound("ding");
  } else if (state.phase === "ROUND") {
    if (state.currentRound < state.totalRounds) {
      if (state.restDuration > 0) {
        state.phase = "REST";
        state.timeLeft = state.restDuration;
        playSound("endBell");
      } else {
        state.phase = "ROUND";
        state.currentRound++;
        state.timeLeft = state.roundDuration;
        playSound("ding");
      }
    } else {
      state.phase = "DONE";
      state.timeLeft = 0;
      playSound("endBell");
      pauseTimer();
      // Play end bell 3 times like in Flutter app
      setTimeout(() => playSound("endBell"), 400);
      setTimeout(() => playSound("endBell"), 800);
    }
  } else if (state.phase === "REST") {
    state.phase = "ROUND";
    state.currentRound++;
    state.timeLeft = state.roundDuration;
    playSound("ding");
  }
}

// Display Logic
function updateDisplay() {
  // Time
  const mins = Math.floor(state.timeLeft / 60);
  const secs = state.timeLeft % 60;
  els.minutes.textContent = mins.toString().padStart(2, "0");
  els.seconds.textContent = secs.toString().padStart(2, "0");

  // Round
  els.currentRound.innerHTML = `ROUND ${state.currentRound} <span class="text-[#543b3c]">/ ${state.totalRounds}</span>`;

  // Status & Progress
  let totalDuration = state.roundDuration;
  if (state.phase === "REST") totalDuration = state.restDuration;
  if (state.phase === "PREP") totalDuration = state.prepDuration;

  let progress = 0;

  // Reset classes
  els.progressBar.classList.remove("bg-green-500", "bg-primary", "bg-blue-500");

  if (state.phase === "READY") {
    els.status.textContent = "Ready";
    els.subStatus.textContent = "Press Play to Start";
    els.progressBar.classList.add("bg-primary");
  } else if (state.phase === "PREP") {
    els.status.textContent = "Get Ready";
    els.subStatus.textContent = "Next: Round 1";
    progress = ((totalDuration - state.timeLeft) / totalDuration) * 100;
    els.progressBar.classList.add("bg-blue-500");
  } else if (state.phase === "ROUND") {
    els.status.textContent = "Training"; // Or "Fight!"
    els.subStatus.textContent = `Next: Rest (${formatDuration(
      state.restDuration
    )})`;
    progress = ((totalDuration - state.timeLeft) / totalDuration) * 100;
    els.progressBar.classList.add("bg-primary");
  } else if (state.phase === "REST") {
    els.status.textContent = "Rest";
    els.subStatus.textContent = `Next: Round ${state.currentRound + 1}`;
    progress = ((totalDuration - state.timeLeft) / totalDuration) * 100;
    els.progressBar.classList.add("bg-green-500");
  } else if (state.phase === "DONE") {
    els.status.textContent = "Finished";
    els.subStatus.textContent = "Great Workout!";
    progress = 100;
    els.progressBar.classList.add("bg-primary");
  }

  els.progressBar.style.width = `${progress}%`;
  els.progressText.textContent = `${Math.round(progress)}%`;
}

function formatDuration(secs) {
  const m = Math.floor(secs / 60);
  const s = secs % 60;
  return `${m}:${s.toString().padStart(2, "0")}`;
}

// Settings Logic
function adjustPrepDuration(amount) {
  state.prepDuration += amount;
  if (state.prepDuration < 0) state.prepDuration = 0;
  if (state.prepDuration > 60) state.prepDuration = 60;
  els.prepInput.value = formatDuration(state.prepDuration);
}

function adjustRoundDuration(amount) {
  state.roundDuration += amount;
  if (state.roundDuration < 10) state.roundDuration = 10;
  if (state.roundDuration > 600) state.roundDuration = 600;
  els.roundInput.value = formatDuration(state.roundDuration);
  if (state.phase === "READY" || state.phase === "ROUND") {
    state.timeLeft = state.roundDuration;
    updateDisplay();
  }
}

function adjustRestDuration(amount) {
  state.restDuration += amount;
  if (state.restDuration < 0) state.restDuration = 0;
  if (state.restDuration > 300) state.restDuration = 300;
  els.restInput.value = formatDuration(state.restDuration);
}

globalThis.adjustTime = function (id, amount) {
  if (state.isRunning) return;

  if (id === "prep-duration") {
    adjustPrepDuration(amount);
  } else if (id === "round-duration") {
    adjustRoundDuration(amount);
  } else if (id === "rest-duration") {
    adjustRestDuration(amount);
  }
};

globalThis.adjustRounds = function (amount) {
  if (state.isRunning) return;

  state.totalRounds += amount;
  if (state.totalRounds < 1) state.totalRounds = 1;
  if (state.totalRounds > 50) state.totalRounds = 50;
  els.roundsInput.value = state.totalRounds;
  updateDisplay();
};

globalThis.setRoundDuration = function (seconds) {
  if (state.isRunning) return;

  state.roundDuration = seconds;
  els.roundInput.value = formatDuration(state.roundDuration);
  if (state.phase === "READY" || state.phase === "ROUND") {
    state.timeLeft = state.roundDuration;
    updateDisplay();
  }
};

globalThis.setRestDuration = function (seconds) {
  if (state.isRunning) return;

  state.restDuration = seconds;
  els.restInput.value = formatDuration(state.restDuration);
};

function toggleSound() {
  state.soundEnabled = !state.soundEnabled;
  els.soundToggle.checked = state.soundEnabled;
  updateSoundIcon();
}

function toggleMobileMenu() {
  if (els.sidebar && els.menuBackdrop) {
    const isOpen = !els.sidebar.classList.contains("-translate-x-full");

    if (isOpen) {
      // Close menu
      els.sidebar.classList.add("-translate-x-full");
      els.menuBackdrop.classList.add("opacity-0", "pointer-events-none");
    } else {
      // Open menu
      els.sidebar.classList.remove("-translate-x-full");
      els.menuBackdrop.classList.remove("opacity-0", "pointer-events-none");
    }
  }
}

function updateSoundIcon() {
  if (state.soundEnabled) {
    els.muteIcon.textContent = "volume_up";
    els.muteBtn.classList.remove("opacity-50");
  } else {
    els.muteIcon.textContent = "volume_off";
    els.muteBtn.classList.add("opacity-50");
  }
}

function playSound(name) {
  if (!state.soundEnabled) return;

  const sound = sounds[name];
  if (sound) {
    sound.currentTime = 0;
    sound.play().catch((e) => console.log("Audio play failed:", e));
  }
}

// Start
init();

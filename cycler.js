const DEFAULT_INTERVAL_SECONDS = 30;
const LOAD_TIMEOUT_MS = 20000;
const PLAYLIST_POLL_MS = 10000;
const PLAYLIST_URL = "./playlist.json";

const frame = document.getElementById("frame");

let playlist = {
  intervalSeconds: DEFAULT_INTERVAL_SECONDS,
  items: [],
};
let index = 0;
let advanceTimer = 0;
let loadTimer = 0;

function itemDurationMs(item) {
  const seconds =
    item.durationSeconds ??
    playlist.intervalSeconds ??
    DEFAULT_INTERVAL_SECONDS;
  return seconds * 1000;
}

function clearTimers() {
  window.clearTimeout(advanceTimer);
  window.clearTimeout(loadTimer);
}

function schedulePlaylistCheck() {
  advanceTimer = window.setTimeout(() => {
    next();
  }, PLAYLIST_POLL_MS);
}

async function fetchPlaylist() {
  const response = await fetch(`${PLAYLIST_URL}?t=${Date.now()}`, {
    cache: "no-store",
  });

  if (!response.ok) {
    throw new Error(`playlist ${response.status}`);
  }

  const data = await response.json();
  const items = Array.isArray(data.items) ? data.items : [];

  return {
    intervalSeconds: data.intervalSeconds ?? DEFAULT_INTERVAL_SECONDS,
    items: items.filter((item) => item && typeof item.url === "string"),
  };
}

function show(item, stay) {
  clearTimers();

  if (stay && frame.src === item.url) {
    schedulePlaylistCheck();
    return;
  }

  loadTimer = window.setTimeout(() => {
    next();
  }, LOAD_TIMEOUT_MS);

  frame.onload = () => {
    clearTimers();
    if (stay) {
      schedulePlaylistCheck();
      return;
    }
    advanceTimer = window.setTimeout(() => {
      next();
    }, itemDurationMs(item));
  };

  frame.src = item.url;
}

async function next() {
  try {
    playlist = await fetchPlaylist();
  } catch {
    // Keep the last good playlist if a refetch fails.
  }

  const items = playlist.items;
  if (items.length === 0) {
    return;
  }

  if (items.length === 1) {
    index = 0;
    show(items[0], true);
    return;
  }

  index = index % items.length;
  const item = items[index];
  index += 1;
  show(item, false);
}

next();

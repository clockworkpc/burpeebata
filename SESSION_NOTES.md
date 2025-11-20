# Burbata - Flutter Tabata Timer for Burpee Workouts

## Session Date: 2025-11-20

## Project Overview

A Flutter app (Android/iOS) for tabata timing specifically for burpee workouts.

### Burpee Types Supported

1. **6-Count Military Burpee**
   - A six-part compound movement recruiting every major muscle group
   - Emphasizes leg and posterior chain work (counts 1-2, 5-6)
   - Upper body work in middle (counts 3-4)
   - Excels at building leg strength and cardiovascular fitness

2. **Navy Seal Burpee**
   - 10 component parts - "the stuff of legend" for upper body
   - Begins/ends with leg work (counts 1-2, 9-10)
   - Upper body dominates counts 3-8 (core, chest, shoulders, triceps, scapula, traps, lats)
   - Superior for building upper body strength and muscle mass

Reference: https://busydadtraining.com/the-two-sacred-movements/

## MVP Goals

1. Tabata timer for burpee workouts
2. Log each workout (completed or not)
3. Allow user to share completed workout

## Post-MVP Goals

### Input Parameters
- Number of reps per set
- Number of seconds per set
- Number of sets in the workout
- Rest time between sets (seconds)

### Audio System
- Countdown sound (3 seconds before each set)
- Sports whistle at start of set
- Boxing bell at end of set

### User Experience
- Workout success prompt at completion
- Material Design UI
- Input validation
- Screen stays on during workout
- Back button confirmation

### Future Features
1. Delete saved workouts
2. Generate graphs and visual data of progress
3. Algorithm to rate workout difficulty based on:
   - Overall volume
   - Total time under tension
   - Average seconds per rep
   - Seconds of rest between sets
4. Camera recording while tabata timer runs

## Technical Setup

- **Project Name:** burbata
- **Organization:** com.burbata
- **Platforms:** Android, iOS
- **Environment:** Dockerized Flutter (Flutter not installed on host)

## Files Created

- `Dockerfile` - Flutter development container
- `docker-compose.yml` - Docker compose configuration
- `flutter.sh` - Helper script to run Flutter commands via Docker

## Next Steps

1. Build Docker image: `docker compose build`
2. Create Flutter project: `./flutter.sh create --org com.burbata --project-name burbata --platforms android,ios .`
3. Implement data models
4. Build tabata timer core functionality
5. Create UI
6. Add workout logging with local storage
7. Implement share functionality

## Current Work: Issue #3 - Add Audio Cues

**GitHub Issue:** https://github.com/clockworkpc/burpeebata/issues/3

### Requirements
- Countdown audio 3 seconds before start of set
- Sports whistle to start a set
- Boxing ring bell to end a set

### Progress

**Completed:**
- [x] Research audio playback options in Flutter
  - Recommended package: `audioplayers` - simple, well-maintained, perfect for short sound effects
  - Alternative: `just_audio` for more complex needs

**In Progress:**
- [ ] Source/create audio files (countdown beeps, sports whistle, boxing bell)
  - Created `assets/audio/` directory
  - CC0 sources identified:
    - **Boxing bell:** BigSoundBank (https://bigsoundbank.com/boxing-bell-1-s1926.html) - CC0
    - **Countdown beep:** Pixabay (https://pixabay.com/sound-effects/search/countdown%20beep/) - CC0
    - **Whistle:** Mixkit (https://mixkit.co/free-sound-effects/whistle/) - royalty-free

**Pending:**
- [ ] Set up audio player package in Flutter project
- [ ] Implement countdown audio (3 seconds before set start)
- [ ] Implement sports whistle sound for set start
- [ ] Implement boxing ring bell sound for set end
- [ ] Test audio cues with workout timer flow

### Implementation Notes

**Timer Service Integration Points** (`lib/services/timer_service.dart`):
- Audio cues should trigger at state transitions:
  - `countdown` state: Play beep each second (3, 2, 1)
  - `countdown` → `work`: Play whistle (set start)
  - `work` → `rest` or `work` → `finished`: Play bell (set end)

**Key Files:**
- `lib/services/timer_service.dart` - Timer state machine
- `lib/screens/timer_screen.dart` - UI that listens to timer

### Next Steps
1. Download audio files from identified CC0 sources
2. Add `audioplayers` package to `pubspec.yaml`
3. Create `AudioService` class
4. Integrate audio triggers into `TimerService`

## Commands Reference

```bash
# Build the Docker image
docker compose build

# Run Flutter commands
./flutter.sh <command>

# Examples:
./flutter.sh create --org com.burbata --project-name burbata --platforms android,ios .
./flutter.sh pub get
./flutter.sh build apk
./flutter.sh build ios
```

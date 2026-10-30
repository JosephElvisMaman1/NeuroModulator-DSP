# Contributing to NeuroModulator DSP

Thank you for your interest in contributing to **NeuroModulator DSP**!

## Development Guidelines

1. **DSP Kernel (C++20)**:
   - Must adhere to deterministic, allocation-free execution in the audio thread (`process()` and `process_smart_overlay()`).
   - Use the pre-allocated `LockFreeRingBuffer` and atomic parameter blocks.
   - Avoid `malloc`, `new`, mutex locks, and unbounded loops inside the audio path.

2. **Flutter UI & Dart FFI**:
   - Zero-copy memory access via `package:ffi` (`Pointer<Float>`).
   - Preserve trilingual support (`AppLocalizations` for `EN`, `ES`, `ZH`).
   - Ensure widget tests pass (`flutter test`).

## Pull Request Process

1. Fork the repository and create a feature branch (`git checkout -b feature/awesome-modulation`).
2. Verify code quality:
   ```bash
   flutter analyze
   flutter test
   ```
3. Commit your changes with clear messages (`git commit -m "Add adaptive binaural carrier modulation"`).
4. Push to your branch and open a Pull Request.

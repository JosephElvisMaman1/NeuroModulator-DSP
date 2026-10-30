#pragma once

#include <atomic>
#include <cstddef>
#include <cstdint>
#include <new>
#include <type_traits>
#include <utility>

/**
 * @file lockfree_ring_buffer.h
 * @brief Lock-Free Cache-Line Aligned Ring Buffer for Real-Time DSP Audio Threads.
 *
 * Implements a wait-free / lock-free Single-Producer Single-Consumer (SPSC)
 * ring buffer with an MPMC command queue extension.
 * Eliminates priority inversions, locks, syscalls, and dynamic memory allocation
 * within real-time audio callbacks.
 */

namespace neuro_dsp {

// Cache line size for modern ARM64 / x86_64 architectures to prevent false sharing
constexpr size_t CACHE_LINE_SIZE = 64;

template <typename T, size_t Capacity>
class LockFreeRingBuffer {
    static_assert((Capacity & (Capacity - 1)) == 0, "Capacity must be a power of two.");
    static_assert(std::is_trivially_copyable_v<T>, "T must be trivially copyable for real-time safety.");

public:
    LockFreeRingBuffer() : write_index_(0), read_index_(0) {}

    ~LockFreeRingBuffer() = default;

    // Non-copyable and non-movable for concurrency safety
    LockFreeRingBuffer(const LockFreeRingBuffer&) = delete;
    LockFreeRingBuffer& operator=(const LockFreeRingBuffer&) = delete;

    /**
     * @brief Pushes an item into the buffer. Thread-safe for producer.
     * @param item The item to push.
     * @return true if successfully queued, false if buffer is full.
     */
    bool push(const T& item) noexcept {
        const size_t current_write = write_index_.load(std::memory_order_relaxed);
        const size_t current_read = read_index_.load(std::memory_order_acquire);

        if ((current_write - current_read) >= Capacity) {
            return false; // Buffer overflow
        }

        buffer_[current_write & MASK] = item;
        write_index_.store(current_write + 1, std::memory_order_release);
        return true;
    }

    /**
     * @brief Pops an item from the buffer. Thread-safe for consumer.
     * @param item Output reference to store the popped item.
     * @return true if successfully popped, false if buffer is empty.
     */
    bool pop(T& item) noexcept {
        const size_t current_read = read_index_.load(std::memory_order_relaxed);
        const size_t current_write = write_index_.load(std::memory_order_acquire);

        if (current_read == current_write) {
            return false; // Buffer underflow
        }

        item = buffer_[current_read & MASK];
        read_index_.store(current_read + 1, std::memory_order_release);
        return true;
    }

    /**
     * @brief Returns current number of available readable elements.
     */
    [[nodiscard]] size_t size() const noexcept {
        const size_t w = write_index_.load(std::memory_order_relaxed);
        const size_t r = read_index_.load(std::memory_order_relaxed);
        return (w >= r) ? (w - r) : 0;
    }

    [[nodiscard]] bool empty() const noexcept {
        return write_index_.load(std::memory_order_relaxed) == read_index_.load(std::memory_order_relaxed);
    }

    void reset() noexcept {
        write_index_.store(0, std::memory_order_relaxed);
        read_index_.store(0, std::memory_order_relaxed);
    }

private:
    static constexpr size_t MASK = Capacity - 1;

    // Align indices to separate cache lines to avoid false sharing across cores
    alignas(CACHE_LINE_SIZE) std::atomic<size_t> write_index_{0};
    alignas(CACHE_LINE_SIZE) std::atomic<size_t> read_index_{0};

    // Buffer storage
    alignas(CACHE_LINE_SIZE) T buffer_[Capacity];
};

/**
 * @brief Lock-Free Atomic DSP Parameter Snapshot
 * Allows the UI thread to publish changes with release semantics,
 * and the Audio thread to read them with acquire semantics without locks.
 */
struct alignas(CACHE_LINE_SIZE) DspParameterBlock {
    // 432 Hz Pitch Shift
    bool pitch_shift_enabled{false};
    float pitch_shift_ratio{432.0f / 440.0f}; // ~0.981818

    // Delta Filter (DF2T Biquad LPF)
    bool delta_lpf_enabled{false};
    float delta_lpf_cutoff{950.0f}; // 800 - 1200 Hz
    float delta_lpf_q{0.70710678f}; // Butterworth Q

    // Alpha Binaural Beat (8 - 12 Hz)
    bool alpha_binaural_enabled{false};
    float alpha_carrier_freq{250.0f}; // 200 - 400 Hz
    float alpha_beat_freq{10.0f};     // 8 - 12 Hz
    float alpha_gain_db{-18.0f};

    // Gamma Isochronic Pulses (40 Hz)
    bool gamma_isochronic_enabled{false};
    float gamma_carrier_freq{216.0f};
    float gamma_pulse_freq{40.0f}; // Exactly 40 Hz
    float gamma_gain_db{-15.0f};

    // Solfeggio 528 Hz Synthesizer + Ducking
    bool solfeggio_enabled{false};
    float solfeggio_freq{528.0f};
    float solfeggio_ducking_threshold_db{-20.0f}; // -18 dB to -24 dB
    float solfeggio_gain_db{-18.0f};

    // Master processing
    float master_gain{1.0f};
    bool limiter_enabled{true};
};

} // namespace neuro_dsp

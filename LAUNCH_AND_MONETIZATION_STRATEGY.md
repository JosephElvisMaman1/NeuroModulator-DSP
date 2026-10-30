# 🚀 Guía Estratégica de Lanzamiento Viral y Monetización Pasiva
### NeuroModulator DSP — Estrategia para Desarrollador Estudiante

Esta guía contiene la hoja de ruta paso a paso para publicar el proyecto, lograr tracción viral en comunidades técnicas y de biohacking, y activar canales de ingresos pasivos y donaciones éticas.

---

## 1. Dónde Publicar el Proyecto (Ecosistema Multiplataforma)

| Plataforma | Tipo de Audiencia | Potencial | Objetivo Principal |
| :--- | :--- | :--- | :--- |
| **GitHub** | Desarrolladores, ingenieros de audio, investigadores | ⭐⭐⭐⭐⭐ (Base) | Ganar estrellas (Stars), forks, colaboradores y activar **GitHub Sponsors**. |
| **Reddit** | Biohackers, audiófilos, desarrolladores Flutter/C++ | ⭐⭐⭐⭐⭐ (Viral) | Conseguir los primeros 1,000–5,000 usuarios orgánicos. |
| **Hacker News (Y Combinator)** | Ingenieros de software de élite, founders, inversores | ⭐⭐⭐⭐⭐ (Alto Impacto) | Llegar a portada (*Show HN*) y generar miles de visitas en 24 horas. |
| **itch.io** | Usuarios indie, entusiastas de software de audio y utilidades | ⭐⭐⭐⭐ (Ingresos) | Permitir descargas con modelo *"Pay What You Want"* (donación voluntaria de $3-$5). |
| **Product Hunt** | Early adopters de tecnología y herramientas de productividad | ⭐⭐⭐⭐ (Visibilidad) | Ganar el "Product of the Day" en la categoría de Audio / AI / Focus. |
| **Gumroad** | Usuarios que buscan herramientas de foco y biohacking | ⭐⭐⭐ (Pasivo) | Descarga digital gratuita con opción de aportar o "Supporter Edition". |

---

## 2. Cómo Generar Ingresos Pasivos y Donaciones (Siendo Estudiante)

Como estudiante, la comunidad de software libre es **extremadamente solidaria** cuando un proyecto combina rigor técnico (C++20, DSP, Flutter) y utilidad real para la salud o productividad:

### Canal A: Donaciones Voluntarias Integradas (0% Fricción)
1. **GitHub Sponsors**: Al ser estudiante, GitHub no cobra comisión. Pon una meta pequeña y transparente (ej: *$50/mes para costear un teléfono Android de prueba para compilar la versión móvil*).
2. **Buy Me a Coffee / Ko-fi**: 
   - Añade un botón en el `README.md`.
   - Puedes colocar un botón discreto en la barra inferior de la propia app de Flutter: *"☕ Apoya a un estudiante desarrollador"*.

### Canal B: Modelo "Pay What You Want" en itch.io
- Sube el `.zip` o instalador de Windows a **itch.io**.
- Configura el precio como **Free / Donation Suggested: $3.00 USD**.
- Muchos usuarios que experimentan mejoras en concentración o sueño con los 40 Hz Gamma o 528 Hz suelen pagar entre $3 y $10 gustosamente.

### Canal C: "Supporter Edition" en Gumroad / itch.io
- La versión base en GitHub es 100% de código abierto y gratuita.
- Ofrece una versión empaquetada *"NeuroModulator Supporter Pack"* que incluye:
  - Instalador ejecutable pre-firmado sin tener que compilar.
  - Pack de 10 presets adicionales de biohacking (ej: *Deep Focus Coding, REM Dream Booster, Lucid Dream Delta, Ultra Zen Alpha*).
  - Guía PDF de neuroacústica avanzada basada en la investigación del proyecto.

---

## 3. Plantillas de Publicación Listas para Copiar y Pegar (Copywriting Viral)

### A. Reddit — r/biohacking y r/audiophile
> **Título**: I built an open-source real-time audio modulator in C++ that adds subliminal brainwave entrainment (432Hz, 40Hz Gamma, 528Hz) to Spotify and YouTube live audio.
>
> **Contenido**:
> Hey everyone! As a CS student fascinated by neuroacoustics and DSP, I always hated static binaural beat MP3s with boring drone sounds. 
>
> I wanted to listen to my normal daily Spotify/YouTube music while getting the cognitive benefits of brainwave entrainment. So I built **NeuroModulator DSP**:
> - It captures live Windows audio via WASAPI Loopback.
> - Runs a 512-sample Phase Vocoder to pitch-shift music to 432 Hz in real time without stretching tempo.
> - Injects 40 Hz Gamma isochronic pulses (backed by MIT Tsai lab research for microglia stimulation).
> - Automatically ducks a 528 Hz Solfeggio sine wave 18 dB below the music using an RMS envelope follower so it remains subliminal.
> - Built with C++20 and Flutter via zero-copy Dart FFI.
>
> It’s 100% open source under MIT License. Check it out and let me know your thoughts: [Tu enlace de GitHub o itch.io]
> Any feedback from fellow audio engineers or biohackers is super appreciated!

### B. Hacker News — Show HN
> **Título**: Show HN: Real-time neuroacoustic modulator in C++20 and Flutter via WASAPI loopback
>
> **Contenido**:
> Hi HN! I'm an independent student developer sharing a project I've been engineering: an OS-level audio modulator that intercepts host audio and applies brainwave entrainment (BWE) with microsecond latency.
>
> Highlights:
> - C++20 DSP core with lock-free ring buffer (64-byte cache-aligned atomic MPMC).
> - Direct Form II Transposed Biquad IIR filter verified against Scipy bilinear transforms.
> - 512-sample Phase Vocoder for real-time Pythagorean tuning (432 Hz).
> - Smart sidechain ducking to keep Solfeggio frequencies below conscious hearing.
> - Flutter desktop UI communicating via zero-copy Dart FFI (`Pointer<Float>`).
>
> Code & Architecture: [Tu enlace de GitHub]
> Would love your feedback on the lock-free audio architecture and DSP pipeline!

### C. Reddit — r/FlutterDev
> **Título**: Built a high-performance Real-Time DSP Audio Modulator using Flutter Desktop and C++20 via Zero-Copy Dart FFI
>
> **Contenido**:
> Sharing a project showing that Flutter Desktop is a great fit for low-latency audio apps when paired with C++ through `dart:ffi`.
> 
> Bypassed Flutter's MethodChannels entirely to prevent GC pause spikes, passing pre-allocated audio buffer pointers directly to an industrial C++20 engine capturing WASAPI loopback.
> 
> Repo link: [Tu enlace de GitHub]

---

## 4. Pasos Inmediatos para Subir la Carpeta a tu GitHub

Una vez que tengas tu cuenta de GitHub lista:

```bash
# 1. Abre PowerShell y entra en la carpeta preparada:
cd "d:\Dev\03_PROYECTOS_PERSONALES\Modulador de Audio Inteligente\Github"

# 2. Inicializa el repositorio local de Git:
git init

# 3. Agrega todos los archivos limpios y templates:
git add .

# 4. Haz tu primer commit profesional:
git commit -m "feat: initial commit - Real-time NeuroModulator DSP engine (C++20, Flutter, WASAPI loopback)"

# 5. Conecta tu repositorio remoto de GitHub (reemplaza con tu URL):
git branch -M main
git remote add origin https://github.com/TU_USUARIO/neuromodulator-dsp.git

# 6. Sube los archivos:
git push -u origin main
```

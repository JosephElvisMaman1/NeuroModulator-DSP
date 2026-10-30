<div align="center">

# 🧠 NeuroModulator DSP
### Motor de Modulación Neuroacústica en Tiempo Real a Nivel de Sistema Operativo

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![C++20](https://img.shields.io/badge/C++-20_Standard-00599C?logo=c%2B%2B&logoColor=white)](https://isocpp.org)
[![Licencia: MIT](https://img.shields.io/badge/Licencia-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Apoya al Desarrollador](https://img.shields.io/badge/Apóyame-BuyMeACoffee%20%2F%20Ko--fi-ffdd00?logo=buy-me-a-coffee&logoColor=black)](#-apoya-al-desarrollador-estudiante)

<p align="center">
  <b>Intercepta cualquier audio en vivo (Spotify, YouTube, Tidal, Windows) e inyecta arrastre de ondas cerebrales (BWE) subliminal e imperceptible con latencia de microsegundos.</b>
</p>

[English](README.md) • [Español](README_ES.md) • [中文](README_ZH.md)

</div>

---

## 🌟 Visión General

**NeuroModulator DSP** es un procesador de audio neuroacústico de código abierto y ultra baja latencia diseñado como una capa DSP intermedia en el sistema operativo. En lugar de reproducir archivos estáticos o MP3s pregrabados, intercepta el flujo de audio que suena en tu ordenador mediante **WASAPI Loopback Capture** y lo modula dinámicamente en tiempo real.

Integra un **Vocoder de Fase a 432 Hz**, filtros IIR bicuadráticos en **Topología Transpuesta de Forma Directa II (DF2T)**, generadores dicóticos binaurales (**Alpha 8–12 Hz**), pulsos isocrónicos (**Gamma 40 Hz**) y un sintetizador senoidal paramétrico de **528 Hz (Solfeggio)** con atenuación inteligente por envolvente RMS (*Ducking* bajo el umbral consciente).

---

## 🔬 Fundamento Científico y Clínico

| Estado Cerebral | Frecuencia Objetivo | Biomarcadores Clínicos | Arquitectura DSP Nativa |
| :--- | :--- | :--- | :--- |
| **Alpha Calm** | 8.0 Hz – 12.0 Hz | Reducción de cortisol (eje HPA), incremento de VFC (HRV) vagal y resonancia armónica natural pitagórica. | Tonos binaurales dicóticos de 200–400 Hz y Vocoder de Fase a 432 Hz (-1.818% sin alterar tempo). |
| **Deep Delta** | 0.5 Hz – 4.0 Hz | Inducción de sueño profundo NREM N3 y supresión del Sistema Reticular Activador Ascendente (SRAA/ARAS). | Filtro de Paso Bajo Bicuadrático DF2T ($F_c = 950\text{ Hz}$) con Transformada Bilineal y pre-deformación. |
| **Gamma Peak** | Exactamente 40.0 Hz | Sincronización tálamo-cortical y activación fagocítica microglial neuroprotectora (Lab Tsai - MIT). | Pulsos isocrónicos AM de coseno alzado ($k = 0.85$ de profundidad de modulación). |
| **Solfeggio 528 Hz** | 528.0 Hz | Resonancia biológica celular y aumento de plasticidad neurotrófica (BDNF/CREB). | Oscilador senoidal puro con atenuación envolvente RMS ($-18\text{ dB}$ a $-24\text{ dB}$ bajo el audio anfitrión). |

---

## 🚀 Guía Rápida de Instalación

```bash
# 1. Clonar el repositorio
git clone https://github.com/JosephElvisMaman1/neuromodulator-dsp.git
cd neuromodulator-dsp

# 2. Descargar dependencias de Flutter
flutter pub get

# 3. Compilar y Ejecutar en Windows Desktop
flutter run -d windows
```

---

## ☕ Apoya al Desarrollador Estudiante

¡Hola! 👋 Soy un estudiante apasionado por el procesamiento digital de señales (DSP), el biohacking acústico y el desarrollo de software de alto rendimiento.

Si este proyecto te resulta útil para concentrarte, dormir mejor o estudiar arquitectura de audio en tiempo real, cualquier donación o estrella en GitHub ayuda enormemente:

- ☕ **Buy Me a Coffee**: [buymeacoffee.com/JoshM1](https://buymeacoffee.com/JoshM1)
- 💖 **GitHub Sponsors**: [github.com/sponsors/JosephElvisMaman1](https://github.com/sponsors/JosephElvisMaman1)
- 🐙 **Perfil de GitHub**: [github.com/JosephElvisMaman1](https://github.com/JosephElvisMaman1)

---

## 📜 Licencia

Distribuido bajo la **Licencia MIT**. Consulta [LICENSE](LICENSE) para más detalles.

import '../models/audio_state.dart';

enum AppLanguage {
  es, // Español
  en, // English
  zh, // 中文 (Chino Simplificado)
}

class AppStrings {
  final AppLanguage lang;

  const AppStrings(this.lang);

  String get appTitle => switch (lang) {
        AppLanguage.es => 'NEURO-DSP MODULADOR INTELIGENTE',
        AppLanguage.en => 'NEURO-DSP INTELLIGENT MODULATOR',
        AppLanguage.zh => 'NEURO-DSP 智能神经声学调制器',
      };

  String get lowLatencyBadge => switch (lang) {
        AppLanguage.es => '512 Muestras / ~2.6 ms Hop',
        AppLanguage.en => '512 Samples / ~2.6 ms Hop',
        AppLanguage.zh => '512 采样 / ~2.6 ms 帧移',
      };

  String get supportButtonLabel => switch (lang) {
        AppLanguage.es => '☕ Apoyar Proyecto',
        AppLanguage.en => '☕ Support Developer',
        AppLanguage.zh => '☕ 支持开发者',
      };

  // Master Power (ON / OFF)
  String get masterPowerTitle => switch (lang) {
        AppLanguage.es => 'INTERRUPTOR MAESTRO DEL SISTEMA DSP',
        AppLanguage.en => 'MASTER DSP SYSTEM POWER SWITCH',
        AppLanguage.zh => 'DSP 系统主电源开关',
      };

  String get masterPowerOnDesc => switch (lang) {
        AppLanguage.es =>
          'ENCENDIDO: Captura WASAPI Loopback activa. Todos los canales pasan por el núcleo C++ en tiempo real.',
        AppLanguage.en =>
          'POWER ON: WASAPI Loopback Capture active. All audio channels route through the real-time C++ core.',
        AppLanguage.zh =>
          '已开启：WASAPI 环回捕获已激活。所有音频通道均实时通过 C++ 核心处理。',
      };

  String get masterPowerOffDesc => switch (lang) {
        AppLanguage.es =>
          'APAGADO (BYPASS): Modulación desactivada. El audio de tu PC (Spotify/YouTube) funciona de manera normal sin intervención.',
        AppLanguage.en =>
          'POWER OFF (BYPASS): Modulation disabled. Your PC audio (Spotify/YouTube) operates normally without intervention.',
        AppLanguage.zh =>
          '已关闭（直通模式）：调制已停用。电脑音频（Spotify/YouTube）正常播放，无任何干预。',
      };

  String get powerButtonOn => switch (lang) {
        AppLanguage.es => 'ENCENDIDO (ACTIVO)',
        AppLanguage.en => 'POWER ON (ACTIVE)',
        AppLanguage.zh => '已开启 (运行中)',
      };

  String get powerButtonOff => switch (lang) {
        AppLanguage.es => 'APAGADO (NORMAL)',
        AppLanguage.en => 'POWER OFF (BYPASS)',
        AppLanguage.zh => '已关闭 (正常模式)',
      };

  // Presets Section
  String get presetsHeader => switch (lang) {
        AppLanguage.es => 'MODOS CLÍNICOS DE ARRASTRE NEUROACÚSTICO (BWE)',
        AppLanguage.en => 'CLINICAL BRAINWAVE ENTRAINMENT (BWE) MODES',
        AppLanguage.zh => '临床脑波夹带 (BWE) 神经声学模式',
      };

  String get presetAlphaLabel => switch (lang) {
        AppLanguage.es => 'Calma Alpha',
        AppLanguage.en => 'Alpha Calm',
        AppLanguage.zh => 'Alpha 平静冥想',
      };

  String get presetDeltaLabel => switch (lang) {
        AppLanguage.es => 'Sueño Delta',
        AppLanguage.en => 'Deep Delta',
        AppLanguage.zh => 'Delta 深度睡眠',
      };

  String get presetGammaLabel => switch (lang) {
        AppLanguage.es => 'Cima Gamma',
        AppLanguage.en => 'Gamma Peak',
        AppLanguage.zh => 'Gamma 认知巅峰',
      };

  String get presetSolfeggioLabel => switch (lang) {
        AppLanguage.es => 'Solfeggio 528',
        AppLanguage.en => 'Solfeggio 528',
        AppLanguage.zh => '528 Hz 细胞修复',
      };

  // Detailed Mode Descriptions
  String modeTitle(NeuroAcousticPreset preset) => switch (preset) {
        NeuroAcousticPreset.alphaMeditation => switch (lang) {
            AppLanguage.es => 'Modo Calma Consciente Alpha (8 Hz - 12 Hz) + Afinación 432 Hz',
            AppLanguage.en => 'Mindful Alpha Calm Mode (8 Hz - 12 Hz) + 432 Hz Tuning',
            AppLanguage.zh => 'Alpha 正念平静模式 (8 Hz - 12 Hz) + 432 Hz 调音',
          },
        NeuroAcousticPreset.deepSleepDelta => switch (lang) {
            AppLanguage.es => 'Modo Sueño Profundo NREM Delta (0.5 Hz - 4 Hz) + Filtro Bicuadrático DF2T',
            AppLanguage.en => 'Deep NREM Sleep Delta Mode (0.5 Hz - 4 Hz) + DF2T Biquad Filter',
            AppLanguage.zh => 'Delta 深度睡眠模式 (0.5 Hz - 4 Hz) + DF2T 双二阶低通滤波',
          },
        NeuroAcousticPreset.gammaCognitiveBoost => switch (lang) {
            AppLanguage.es => 'Modo Optimización Cognitiva Gamma (40.0 Hz Exactos - Protocolo MIT)',
            AppLanguage.en => 'Gamma Cognitive Optimization Mode (Exact 40.0 Hz - MIT Protocol)',
            AppLanguage.zh => 'Gamma 认知优化模式 (精准 40.0 Hz - MIT 蔡氏实验室方案)',
          },
        NeuroAcousticPreset.solfeggioHarmonics => switch (lang) {
            AppLanguage.es => 'Modo Homeostasis Celular Solfeggio (528 Hz) + Ducking Envolvente',
            AppLanguage.en => 'Solfeggio Cellular Homeostasis Mode (528 Hz) + Envelope Ducking',
            AppLanguage.zh => 'Solfeggio 细胞稳态模式 (528 Hz) + 动态包络闪避',
          },
        NeuroAcousticPreset.custom => switch (lang) {
            AppLanguage.es => 'Modo Personalizado de Ingeniería Neuroacústica',
            AppLanguage.en => 'Custom Neuroacoustic Engineering Mode',
            AppLanguage.zh => '自定义神经声学工程模式',
          },
      };

  String modeScientificDesc(NeuroAcousticPreset preset) => switch (preset) {
        NeuroAcousticPreset.alphaMeditation => switch (lang) {
            AppLanguage.es =>
              '• Fundamento Clínico: Induce vigilia relajada mediante batidos binaurales dicóticos procesados en el complejo olivar superior. Incrementa la potencia de alta frecuencia (HF) en la variabilidad cardíaca (HRV), activa el tono vagal parasimpático y reduce el estrés agudo (DASS-21).\n'
              '• Intervención DSP: Vocoder de fase a 432 Hz (-1.818% para atenuar el cortisol salival en el eje HPA) + Generador dicótico anclado en portadora cálida de 250 Hz con desfase de 10 Hz.',
            AppLanguage.en =>
              '• Clinical Foundation: Induces relaxed wakefulness via dichotic binaural beats processed in the superior olivary complex. Increases High-Frequency (HF) heart rate variability (HRV), activates parasympathetic vagal tone, and reduces acute stress (DASS-21).\n'
              '• DSP Intervention: 432 Hz Phase Vocoder (-1.818% to attenuate salivary cortisol in the HPA axis) + Dichotic generator anchored at a 250 Hz warm carrier with a 10 Hz beat offset.',
            AppLanguage.zh =>
              '• 临床机制：通过上橄榄复合体处理的双耳分听节拍诱导放松清醒状态。显著提高心率变异性 (HRV) 的高频功率 (HF)，激活副交感迷走神经张力并减轻急性压力 (DASS-21)。\n'
              '• DSP 干预：432 Hz 相位声码器（整体谐波降低 -1.818% 以降低唾液皮质醇）+ 锚定在 250 Hz 温暖载波上的 10 Hz 双耳节拍发生器。',
          },
        NeuroAcousticPreset.deepSleepDelta => switch (lang) {
            AppLanguage.es =>
              '• Fundamento Clínico: Prolonga la fase N3 de sueño de ondas lentas (NREM) para el lavado glinfático y consolidación de memoria. Silencia transitorios agudos que activan el Sistema Reticular Activador Ascendente (SARA), evitando micro-despertares.\n'
              '• Intervención DSP: Filtro IIR Bicuadrático de Paso Bajo (LPF) en Topología Transpuesta de Forma Directa II (DF2T) con Transformación Bilineal pre-deformada (corte en 900 Hz) + afinación a 432 Hz.',
            AppLanguage.en =>
              '• Clinical Foundation: Prolongs stage N3 slow-wave sleep (NREM) for glymphatic clearance and memory consolidation. Silences high-frequency transients that trigger the Ascending Reticular Activating System (ARAS), preventing micro-arousals.\n'
              '• DSP Intervention: Dynamic IIR Low-Pass Filter (LPF) in Transposed Direct Form II (DF2T) with pre-warped Bilinear Transform (900 Hz cutoff) + 432 Hz pitch shifting.',
            AppLanguage.zh =>
              '• 临床机制：延长 N3 期慢波深度睡眠 (NREM)，促进脑部淋巴排毒与记忆巩固。消除会触发上行网状激活系统 (ARAS) 的高频瞬态噪声，防止夜间微觉醒。\n'
              '• DSP 干预：采用预畸变双线性变换的转置直接 II 型 (DF2T) 双二阶低通滤波器（900 Hz 截止频率）+ 432 Hz 调音。',
          },
        NeuroAcousticPreset.gammaCognitiveBoost => switch (lang) {
            AppLanguage.es =>
              '• Fundamento Clínico: Basado en las investigaciones del MIT (Laboratorio Tsai). La estimulación auditiva a exactamente 40 Hz induce respuestas de estado estable (ASSR), activa la microglía para fagocitar placas beta-amiloides y potencia la memoria de trabajo y el enfoque.\n'
              '• Intervención DSP: Pulsos isocrónicos modulados en amplitud con envolvente cosenoidal elevada a 40.0 Hz exactos sobre portadora de 216 Hz (evitando la aspereza de los batidos binaurales > 30 Hz).',
            AppLanguage.en =>
              '• Clinical Foundation: Grounded in MIT Tsai Lab research. Sensory stimulation at exactly 40 Hz induces Auditory Steady-State Responses (ASSR), stimulates microglia to clear beta-amyloid plaques, and boosts working memory and focus.\n'
              '• DSP Intervention: Amplitude-modulated isochronic pulses with a smooth raised-cosine envelope at exactly 40.0 Hz over a 216 Hz carrier (avoiding binaural roughness > 30 Hz).',
            AppLanguage.zh =>
              '• 临床机制：基于麻省理工学院 (MIT 蔡氏实验室) 研究。精准 40 Hz 听觉刺激可诱发听觉稳态响应 (ASSR)，激活小胶质细胞吞噬 β-淀粉样蛋白斑块，显著提升工作记忆与专注力。\n'
              '• DSP 干预：在 216 Hz 载波上施加精准 40.0 Hz 升余弦包络等时脉冲幅度调制（避免 >30 Hz 双耳节拍产生的听觉粗糙感）。',
          },
        NeuroAcousticPreset.solfeggioHarmonics => switch (lang) {
            AppLanguage.es =>
              '• Fundamento Clínico: La exposición controlada a ondas puras de 528 Hz reduce especies reactivas de oxígeno (ROS) en tejido neuronal, disminuye el cortisol sistémico e incrementa oxitocina, BDNF y CREB (neuroplasticidad y viabilidad celular).\n'
              '• Intervención DSP: Sintetizador senoidal paramétrico sin deriva a 528.0 Hz acoplado a un seguidor de envolvente RMS asimétrico (Ducking) que mantiene el tono entre -18 dB y -24 dB bajo la música principal.',
            AppLanguage.en =>
              '• Clinical Foundation: Controlled exposure to pure 528 Hz waves reduces reactive oxygen species (ROS) in neural tissue, lowers systemic cortisol, and elevates oxytocin, BDNF, and CREB (neuroplasticity and cellular viability).\n'
              '• DSP Intervention: Zero-drift 528.0 Hz parametric sine synthesizer coupled with an asymmetric RMS envelope follower (Ducking) keeping the tone -18 dB to -24 dB below the host music.',
            AppLanguage.zh =>
              '• 临床机制：受控的 528 Hz 纯正弦波暴露可减少神经组织中的活性氧 (ROS)，降低全身皮质醇，并提升催产素、BDNF 和 CREB（增强神经可塑性与细胞活力）。\n'
              '• DSP 干预：零漂移 528.0 Hz 参数正弦合成器，配合非对称 RMS 包络跟随器（动态闪避），使音调始终保持在主音乐下方 -18 dB 至 -24 dB 的潜意识阈值内。',
          },
        NeuroAcousticPreset.custom => switch (lang) {
            AppLanguage.es =>
              '• Configuración manual activa: Combina libremente el Vocoder de 432 Hz, el filtro bicuadrático DF2T, y las capas de síntesis aditiva en tiempo real.',
            AppLanguage.en =>
              '• Manual configuration active: Freely combine the 432 Hz Phase Vocoder, DF2T Biquad filter, and real-time additive synthesis layers.',
            AppLanguage.zh =>
              '• 手动配置已激活：自由组合 432 Hz 相位声码器、DF2T 双二阶滤波器及实时加性合成层。',
          },
      };

  // Module 1: Pitch Shifter
  String get pitchCardTitle => switch (lang) {
        AppLanguage.es => 'Afinación Armónica 432 Hz (Vocoder de 512 Muestras)',
        AppLanguage.en => '432 Hz Harmonic Pitch Shifter (512-Sample Vocoder)',
        AppLanguage.zh => '432 Hz 谐波移调器 (512 采样相位声码器)',
      };

  String get pitchCardSub => switch (lang) {
        AppLanguage.es => 'Desplazamiento espectral de -1.818% sin alterar el tempo original',
        AppLanguage.en => '-1.818% spectral downshift without altering original tempo',
        AppLanguage.zh => '-1.818% 频谱下移，完全保持原始节奏与速度',
      };

  String get pitchCardBody => switch (lang) {
        AppLanguage.es =>
          'Re-sintetiza el espectro armónico de 440 Hz a 432 Hz mediante STFT con solapamiento del 75% (128 muestras). Atenúa el eje HPA y reduce la frecuencia cardíaca sin distorsión rítmica.',
        AppLanguage.en =>
          'Re-synthesizes the harmonic spectrum from 440 Hz to 432 Hz via STFT with 75% overlap (128 samples). Attenuates the HPA axis and lowers heart rate without rhythmic distortion.',
        AppLanguage.zh =>
          '通过 75% 重叠率（128 采样帧移）的短时傅里叶变换 (STFT) 将谐波频谱从 440 Hz 重新合成为 432 Hz。有效平缓 HPA 轴压力反应并降低心率。',
      };

  // Module 2: Delta Biquad Filter
  String get deltaCardTitle => switch (lang) {
        AppLanguage.es => 'Filtro Bicuadrático DF2T para Sueño Delta (0.5 - 4 Hz)',
        AppLanguage.en => 'Delta Sleep Transposed Biquad Filter (DF2T)',
        AppLanguage.zh => 'Delta 睡眠转置双二阶滤波器 (DF2T)',
      };

  String get deltaCardSub => switch (lang) {
        AppLanguage.es => 'Filtro IIR de Paso Bajo con Transformación Bilineal pre-deformada',
        AppLanguage.en => 'Dynamic IIR Low-Pass Filter with pre-warped Bilinear Transform',
        AppLanguage.zh => '采用预畸变双线性变换的动态 IIR 低通滤波器',
      };

  String get cutoffSliderLabel => switch (lang) {
        AppLanguage.es => 'Frecuencia de Corte (Fc)',
        AppLanguage.en => 'Cutoff Frequency (Fc)',
        AppLanguage.zh => '截止频率 (Fc)',
      };

  // Module 3: Alpha Binaural
  String get alphaCardTitle => switch (lang) {
        AppLanguage.es => 'Generador Dicótico de Tonos Binaurales Alpha (8 - 12 Hz)',
        AppLanguage.en => 'Alpha Dichotic Binaural Beat Generator (8 - 12 Hz)',
        AppLanguage.zh => 'Alpha 双耳分听节拍发生器 (8 - 12 Hz)',
      };

  String get alphaCardSub => switch (lang) {
        AppLanguage.es => 'Arrastre parasimpático anclado en portadoras cálidas (200 - 400 Hz)',
        AppLanguage.en => 'Parasympathetic entrainment on warm carriers (200 - 400 Hz)',
        AppLanguage.zh => '锚定在温暖载波 (200 - 400 Hz) 上的副交感神经夹带',
      };

  String get alphaBeatLabel => switch (lang) {
        AppLanguage.es => 'Frecuencia de Batido Binaural (Δf)',
        AppLanguage.en => 'Binaural Beat Frequency (Δf)',
        AppLanguage.zh => '双耳节拍频率差 (Δf)',
      };

  String get alphaCarrierLabel => switch (lang) {
        AppLanguage.es => 'Frecuencia Portadora Cálida',
        AppLanguage.en => 'Warm Carrier Frequency',
        AppLanguage.zh => '温暖载波频率',
      };

  String get subliminalGainLabel => switch (lang) {
        AppLanguage.es => 'Ganancia de Inyección Subliminal',
        AppLanguage.en => 'Subliminal Injection Gain',
        AppLanguage.zh => '潜意识注入增益',
      };

  // Module 4: Gamma Isochronic
  String get gammaCardTitle => switch (lang) {
        AppLanguage.es => 'Pulsos Isocrónicos Gamma a 40 Hz Exactos',
        AppLanguage.en => 'Exact 40 Hz Gamma Isochronic Pulses',
        AppLanguage.zh => '精准 40 Hz Gamma 等时脉冲发生器',
      };

  String get gammaCardSub => switch (lang) {
        AppLanguage.es => 'Estimulación ASSR cortical y microglial con envolvente suave',
        AppLanguage.en => 'Cortical & microglial ASSR stimulation with smooth envelope',
        AppLanguage.zh => '具有平滑包络的皮层与小胶质细胞 ASSR 稳态刺激',
      };

  String get gammaPulseRateLabel => switch (lang) {
        AppLanguage.es => 'Frecuencia de Modulación (ASSR)',
        AppLanguage.en => 'Modulation Pulse Rate (ASSR)',
        AppLanguage.zh => '调制脉冲频率 (ASSR)',
      };

  String get gammaCarrierLabel => switch (lang) {
        AppLanguage.es => 'Portadora de Baja Frecuencia',
        AppLanguage.en => 'Low-Frequency Carrier',
        AppLanguage.zh => '低频载波频率',
      };

  String get gammaGainLabel => switch (lang) {
        AppLanguage.es => 'Amplitud de Pulso Isocrónico',
        AppLanguage.en => 'Isochronic Pulse Amplitude',
        AppLanguage.zh => '等时脉冲幅度',
      };

  // Module 5: Solfeggio 528 Hz
  String get solfeggioCardTitle => switch (lang) {
        AppLanguage.es => 'Sintetizador Solfeggio 528 Hz + Sidechain Ducking',
        AppLanguage.en => '528 Hz Solfeggio Synthesizer + Sidechain Ducking',
        AppLanguage.zh => '528 Hz Solfeggio 合成器 + 侧链动态闪避',
      };

  String get solfeggioCardSub => switch (lang) {
        AppLanguage.es => 'Oscilador senoidal puro con seguimiento envolvente RMS automático',
        AppLanguage.en => 'Pure sine oscillator with automatic RMS envelope tracking',
        AppLanguage.zh => '具有自动 RMS 包络跟踪的纯正弦振荡器',
      };

  String get solfeggioDuckingLabel => switch (lang) {
        AppLanguage.es => 'Umbral Consciente (Offset bajo RMS de la Música)',
        AppLanguage.en => 'Conscious Threshold (Offset below Host Music RMS)',
        AppLanguage.zh => '潜意识阈值（低于主音乐 RMS 的偏移量）',
      };

  String get solfeggioNote => switch (lang) {
        AppLanguage.es =>
          'Rastrea en tiempo real el volumen de Spotify/YouTube vía WASAPI Loopback para mantener los 528 Hz entre -18 dB y -24 dB por debajo de tu música.',
        AppLanguage.en =>
          'Tracks Spotify/YouTube volume in real time via WASAPI Loopback to keep 528 Hz strictly -18 dB to -24 dB beneath your music.',
        AppLanguage.zh =>
          '通过 WASAPI 环回实时跟踪 Spotify/YouTube 音量，将 528 Hz 严格保持在音乐下方 -18 dB 至 -24 dB。',
      };

  // Telemetry & WASAPI HUD
  String get telemetryTitle => switch (lang) {
        AppLanguage.es => 'CAPTURA WASAPI LOOPBACK Y TELEMETRÍA EN VIVO',
        AppLanguage.en => 'WASAPI LOOPBACK CAPTURE & LIVE TELEMETRY',
        AppLanguage.zh => 'WASAPI 环回捕获与实时遥测监控',
      };

  String get telemetrySub => switch (lang) {
        AppLanguage.es => 'Intercepción de audio del sistema (Spotify / YouTube) y salida al DAC',
        AppLanguage.en => 'OS system audio interception (Spotify / YouTube) & DAC output',
        AppLanguage.zh => '操作系统音频拦截 (Spotify / YouTube) 与 DAC 硬件输出',
      };

  String get sourceSelectorLabel => switch (lang) {
        AppLanguage.es => 'MODO DE INTERCEPCIÓN / CANAL DE ENTRADA:',
        AppLanguage.en => 'INTERCEPTION MODE / INPUT CHANNEL:',
        AppLanguage.zh => '拦截模式 / 输入通道选择：',
      };

  String get modeWasapiSmart => switch (lang) {
        AppLanguage.es => 'WASAPI Loopback (Spotify/YT)',
        AppLanguage.en => 'WASAPI Loopback (Spotify/YT)',
        AppLanguage.zh => 'WASAPI 环回 (Spotify/YT)',
      };

  String get modeWasapiFull => switch (lang) {
        AppLanguage.es => 'WASAPI Full Wet (432Hz+LPF)',
        AppLanguage.en => 'WASAPI Full Wet (432Hz+LPF)',
        AppLanguage.zh => 'WASAPI 全湿处理 (432Hz+滤波)',
      };

  String get modePad440 => switch (lang) {
        AppLanguage.es => 'Demo Pad 440Hz',
        AppLanguage.en => 'Demo 440Hz Pad',
        AppLanguage.zh => '440Hz 演示音垫',
      };

  String get modePinkNoise => switch (lang) {
        AppLanguage.es => 'Demo Ruido LPF',
        AppLanguage.en => 'Demo LPF Noise',
        AppLanguage.zh => '低通滤波噪声演示',
      };

  String get dacActive => switch (lang) {
        AppLanguage.es => 'WASAPI Loopback + DAC: PROCESANDO EN VIVO',
        AppLanguage.en => 'WASAPI Loopback + DAC: LIVE PROCESSING',
        AppLanguage.zh => 'WASAPI 环回 + DAC：实时处理中',
      };

  String get dacBypass => switch (lang) {
        AppLanguage.es => 'Sistema en Bypass (Audio normal sin modular)',
        AppLanguage.en => 'System in Bypass (Normal unmodulated audio)',
        AppLanguage.zh => '系统直通模式（正常未调制音频）',
      };

  String get samplesProcessed => switch (lang) {
        AppLanguage.es => 'Muestras',
        AppLanguage.en => 'Samples',
        AppLanguage.zh => '已处理采样',
      };

  // Isolated Web Player
  String get webPlayerTitle => switch (lang) {
        AppLanguage.es => 'REPRODUCTOR WEB AISLADO (SPOTIFY / YOUTUBE PWA)',
        AppLanguage.en => 'ISOLATED WEB PLAYER (SPOTIFY / YOUTUBE PWA)',
        AppLanguage.zh => '隔离式网页播放器 (SPOTIFY / YOUTUBE PWA)',
      };

  String get webPlayerSub => switch (lang) {
        AppLanguage.es => 'Contingencia anti-DRM y lanzamiento directo para captura WASAPI',
        AppLanguage.en => 'Anti-DRM contingency & direct launch for WASAPI capture',
        AppLanguage.zh => '反 DRM 应急方案与 WASAPI 捕获直接启动器',
      };

  String get webSandboxDesc => switch (lang) {
        AppLanguage.es =>
          'Al encender el interruptor maestro arriba, cualquier música o video que reproduzcas en Spotify o YouTube será interceptado automáticamente por WASAPI Loopback y modulado en tiempo real.',
        AppLanguage.en =>
          'When the Master Power switch above is turned ON, any music or video playing in Spotify or YouTube is automatically intercepted by WASAPI Loopback and modulated in real time.',
        AppLanguage.zh =>
          '开启上方主电源开关后，在 Spotify 或 YouTube 中播放的任何音乐或视频都将自动被 WASAPI 环回拦截并进行实时神经声学调制。',
      };

  String get openSpotifyBtn => switch (lang) {
        AppLanguage.es => 'Abrir Spotify Web',
        AppLanguage.en => 'Open Spotify Web',
        AppLanguage.zh => '打开 Spotify 网页版',
      };

  String get openYoutubeBtn => switch (lang) {
        AppLanguage.es => 'Abrir YouTube Music',
        AppLanguage.en => 'Open YouTube Music',
        AppLanguage.zh => '打开 YouTube Music',
      };
}

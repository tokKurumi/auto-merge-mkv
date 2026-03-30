# auto-merge-mkv
Bash script to automatically merge (multiplex) audio, subtitles, and fonts into an MKV container.

## Usage

```bash
auto-merge-mkv
Usage:
  auto-merge-mkv.sh \
    --root-folder <path> \
    --sounds-folder <path> \
    --sounds-region <code> \
    --subtitles-folder <path> \
    --subtitles-region <code> \
    --output-folder <path> \
    [--fonts-folder <path>] \
    [--parallel <N>]
Paths may be absolute or relative.
Tracks are matched by exact filename
(e.g., S01E01-Jobless Reincarnation.mkv ↔ S01E01-Jobless Reincarnation.mka/.ass).
Track names are derived from the immediate parent directory
(e.g., Sounds/AniLibria → AniLibria).
```

Example:
```bash
auto-merge-mkv.sh \
    --root-folder . \
    --sounds-folder "AniLibria Rus Sound/" \
    --sounds-region rus \
    --sounds-folder "Studio Band Rus Sound/" \
    --sounds-region rus \
    --subtitles-folder "Crunchyroll Rus Sub/" \
    --subtitles-region rus \
    --subtitles-folder "AniLibria (Надписи) Rus Sub/" \
    --subtitles-region rus \
    --fonts-folder "AniLibria (Надписи) Rus Sub/font/" \
    --output-folder "Merged" \
    --parallel 4
```

This produces `Merged` folder with all audio \ subs \ fonts included for each mkv contaainer:

```bash
tree
.
├── 01. The Death Row Convict and the Executioner.mkv
├── 02. Screening and Choosing.mkv
├── 03. Weakness and Strength.mkv
├── 04. Hell and Paradise.mkv
├── 05. The Samurai and the Woman.mkv
├── 06. Heart and Reason.mkv
├── 07. Flowers and Offerings.mkv
├── 08. Student and Master.mkv
├── 09. Gods and People.mkv
├── 10. Yin and Yang.mkv
├── 11. Weak and Strong.mkv
├── 12. Umbrella and Ink.mkv
├── 13. Dreams and Reality.mkv
├── AniLibria Rus Sound
│   ├── 01. The Death Row Convict and the Executioner.mka
│   ├── 02. Screening and Choosing.mka
│   ├── 03. Weakness and Strength.mka
│   ├── 04. Hell and Paradise.mka
│   ├── 05. The Samurai and the Woman.mka
│   ├── 06. Heart and Reason.mka
│   ├── 07. Flowers and Offerings.mka
│   ├── 08. Student and Master.mka
│   ├── 09. Gods and People.mka
│   ├── 10. Yin and Yang.mka
│   ├── 11. Weak and Strong.mka
│   ├── 12. Umbrella and Ink.mka
│   └── 13. Dreams and Reality.mka
├── AniLibria (Надписи) Rus Sub
│   ├── 01. The Death Row Convict and the Executioner.ass
│   ├── 02. Screening and Choosing.ass
│   ├── 03. Weakness and Strength.ass
│   ├── 04. Hell and Paradise.ass
│   ├── 05. The Samurai and the Woman.ass
│   ├── 06. Heart and Reason.ass
│   ├── 07. Flowers and Offerings.ass
│   ├── 08. Student and Master.ass
│   ├── 09. Gods and People.ass
│   ├── 10. Yin and Yang.ass
│   ├── 11. Weak and Strong.ass
│   ├── 12. Umbrella and Ink.ass
│   ├── 13. Dreams and Reality.ass
│   └── font
│       ├── 3966.ttf
│       ├── 8EnCFzJL.ttf
│       ├── ARIALBD.TTF
│       ├── ARIALBI.TTF
│       ├── ARIALI.TTF
│       ├── ARIALN.TTF
│       ├── ARIAL.TTF
│       ├── ARIBLK.TTF
│       ├── CORRID.ttf
│       ├── ds_broadbrush.ttf
│       ├── E2nNPZYI.ttf
│       ├── FSuGY8Oa.ttf
│       ├── georgiab.ttf
│       ├── georgiai.ttf
│       ├── georgia.ttf
│       ├── georgiaz.ttf
│       ├── Roboto-Light.ttf
│       ├── segoeprA.ttf
│       ├── timesbd.ttf
│       ├── timesbi.ttf
│       ├── timesi.ttf
│       ├── times.ttf
│       └── tt0142m.ttf
├── Merged
│   ├── 01. The Death Row Convict and the Executioner.mkv
│   ├── 02. Screening and Choosing.mkv
│   ├── 03. Weakness and Strength.mkv
│   ├── 04. Hell and Paradise.mkv
│   ├── 05. The Samurai and the Woman.mkv
│   ├── 06. Heart and Reason.mkv
│   ├── 07. Flowers and Offerings.mkv
│   ├── 08. Student and Master.mkv
│   ├── 09. Gods and People.mkv
│   ├── 10. Yin and Yang.mkv
│   ├── 11. Weak and Strong.mkv
│   ├── 12. Umbrella and Ink.mkv
│   └── 13. Dreams and Reality.mkv
├── Studio Band Rus Sound
│   ├── 01. The Death Row Convict and the Executioner.mka
│   ├── 02. Screening and Choosing.mka
│   ├── 03. Weakness and Strength.mka
│   ├── 04. Hell and Paradise.mka
│   ├── 05. The Samurai and the Woman.mka
│   ├── 06. Heart and Reason.mka
│   ├── 07. Flowers and Offerings.mka
│   ├── 08. Student and Master.mka
│   ├── 09. Gods and People.mka
│   ├── 10. Yin and Yang.mka
│   ├── 11. Weak and Strong.mka
│   ├── 12. Umbrella and Ink.mka
│   └── 13. Dreams and Reality.mka
└── Сrunchyroll Rus Sub
    ├── 01. The Death Row Convict and the Executioner.ass
    ├── 02. Screening and Choosing.ass
    ├── 03. Weakness and Strength.ass
    ├── 04. Hell and Paradise.ass
    ├── 05. The Samurai and the Woman.ass
    ├── 06. Heart and Reason.ass
    ├── 07. Flowers and Offerings.ass
    ├── 08. Student and Master.ass
    ├── 09. Gods and People.ass
    ├── 10. Yin and Yang.ass
    ├── 11. Weak and Strong.ass
    ├── 12. Umbrella and Ink.ass
    └── 13. Dreams and Reality.ass
```

> Note: Do not point to the final directory containing media files directly.
Use the parent ("wrapper") directory instead.
All contained tracks will be merged, and the folder name will be used as the track name.


## Dependencies
- mkvtoolnix - core CLI package to multiplex several files;
- parallel - optionall CLI tool that allows parallel execution;
- findutils + coreutils - misc utils for internal logic.

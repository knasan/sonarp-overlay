# sonarp-overlay

Gentoo overlay for [SonarPractice](https://github.com/sonar-project/SonarPractice) and [libgp_parser](https://github.com/sonar-project/libgp_parser).

## Packages

| Package | Description |
| --- | --- |
| `media-libs/libgp_parser` | C++23 Guitar Pro parser (shared library) |
| `media-sound/sonarpractice` | Practice hub Qt6 application |

## Setup

Add the overlay to Portage (as root):

```bash
cat > /etc/portage/repos.conf/sonarp.conf << 'EOF'
[sonarp]
location = /home/smk/Develop/Projects/sonarp-overlay
masters = gentoo
auto-sync = no
EOF

# optional convenience link
ln -sfn /home/smk/Develop/Projects/sonarp-overlay /var/db/repos/sonarp
```

Optional USE flags (`/etc/portage/package.use`):

```
media-sound/sonarpractice webengine ffmpeg
dev-qt/qtwebengine qml
dev-qt/qtbase:6 concurrent gui sql sqlite widgets
dev-qt/qttools:6 linguist
```

## Install

```bash
emerge -av media-libs/libgp_parser
emerge -av media-sound/sonarpractice
```

Live ebuilds (`9999`) track git HEAD. Pair them:

```bash
emerge -av =media-libs/libgp_parser-9999 =media-sound/sonarpractice-9999
```

For local git checkouts, edit `EGIT_REPO_URI` in the `9999` ebuilds to
`file:///home/smk/Develop/Projects/libgp_parser` /
`file:///home/smk/Develop/Projects/SonarPractice`.

## Notes

- App depends on Portage Qt `>=6.11:6` (not the Qt Maintenance Tool under `~/Qt`).
- `sonarpractice-0.1.0` rewrites `cmake/Dependencies.cmake` at prepare time so the
  tagged release uses system `libgp_parser` instead of FetchContent.
- RubberBand is still bundled via FetchContent in the app ebuild.

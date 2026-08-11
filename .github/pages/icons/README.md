# Package icons

Vendored SVGs from [Simple Icons](https://simpleicons.org), used as the logos on
the releases page.

Vendored rather than hotlinked from a CDN on purpose: the page then has no
third-party runtime dependency, does not leak visitor IPs to a CDN, and cannot
break when an upstream URL moves.

## Licensing

The Simple Icons collection is **CC0-1.0** — see
[simple-icons/LICENSE.md](https://github.com/simple-icons/simple-icons/blob/develop/LICENSE.md).

The *trademarks* remain the property of their respective owners. These marks are
used here nominatively, to identify which upstream project each build came from.
That is normal use, but a few projects publish brand guidelines worth honouring
if the page ever grows beyond a listing — Docker, Kubernetes, Python and the FSF
all have them. Do not restyle a mark into something that could read as an
endorsement by the upstream project.

## Refreshing

```bash
.github/pages/icons/fetch-icons.sh
```

That rewrites the SVGs and recomputes the `icon`, `icon_color` and
`icon_color_dark` fields in `../packages.json`.

## Why the colours are recomputed

Brand colours are not chosen for our two backgrounds. Lua's `#000080` is
invisible on the dark theme; Nim's `#FFE953` is invisible on the light one. The
script keeps each brand's hue and saturation but clamps lightness into a legible
band per theme, so the icons stay recognisable without disappearing.

Packages with no Simple Icons entry get a monogram tile instead, with a hue
derived from a hash of the package id — stable across rebuilds.

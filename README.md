# Greenbar slides

A simple Typst slide template. The page is framed with a green-themed header and
footer (modeled after the Beamer CambridgeUS template) and uses the CMU
(Computer Modern Unicode) family of fonts.

![An example title page slide](assembly-1.png)

![An example regular slide](assembly-10.png)


## Getting started

Make sure you have the CMU fonts installed. From Debian-based systems:

    sudo apt install fonts-cmu

Import the template and apply it with `#show`:

```typ
#import "greenbar.typ": *

#show: slides.with(
  title: [Programming Languages],
  short-title: [CS 3520],
  subtitle: [Types],
  author: [Dr Russ Ross],
  short-author: [Dr Russ Ross],
  institute: [Utah Tech University—Department of Computing],
  short-institute: [Computing],
  date: [Fall 2025],
)
```

Then write your deck using standard Typst headings:

- `=` sets the current **section** for the running header and PDF bookmarks
- `==` sets the current **topic** for the running header and PDF bookmarks
- `===` starts a **new slide** and supplies that slide's title
- `====` creates a styled **subheading** inside a slide body

```typ
= Introduction to Types

=== Introduction to Types

We will use the term _type_ to refer to a _static_ check.

== A Standard Model of Types

=== A Standard Model of Types

Types are an abstraction of run-time values.
```

The deck always starts with a title page. Slides begin at each `===` heading. If
content runs long, it naturally continues onto following pages with the same
slide title and header/footer styling.


## Configuration

All parameters to `slides()` are optional except the body:

| Parameter          | Default                    | Description                          |
|--------------------|----------------------------|--------------------------------------|
| `title`            | `[Untitled]`               | Title shown on the title slide       |
| `subtitle`         | `none`                     | Line below the title                 |
| `short-title`      | `auto`                     | Footer title; defaults to `title`    |
| `author`           | `none`                     | Author line on the title slide       |
| `short-author`     | `auto`                     | Footer author; defaults to `author`  |
| `institute`        | `none`                     | Institute line on the title slide    |
| `short-institute`  | `none`                     | Short institute for the footer       |
| `date`             | `none`                     | Date on title slide and footer       |
| `color`            | `rgb(0, 77, 0)`            | Primary accent color                 |
| `text-font`        | `"CMU Serif"`              | Main body font                       |
| `heading-font`     | `"CMU Sans Serif"`         | Header/title/heading font            |
| `mono-font`        | `"CMU Typewriter Text"`    | Code/raw text font                   |
| `math-font`        | `"New Computer Modern Math"` | Math font                          |
| `text-size`        | `9pt`                      | Base body size                       |
| `mono-scale`       | `auto`                     | Inline code size relative to text    |
| `block-mono-scale` | `auto`                     | Block code size relative to body text |
| `aspect-ratio`     | `"16-9"`                   | `"16-9"` or `"4-3"`                 |

With the defaults, the footer shows:

- left: `short-author (short-institute)` when both are present, with sensible fallbacks
- middle: `short-title`
- right: `date` and `current/total` page numbering


## Building

Compile a deck with the Typst CLI:

```sh
typst compile types.typ
```

or even better:

```sh
typst watch types.typ
```

which automatically recompiles whenever you save changes.

/// Slide template for "authored-content-first" decks.
///
/// The design goal is: authors mostly write headings and content, while this
/// template handles page chrome, title pages, footer metadata, and outline
/// bookmarks automatically.
///
/// Authoring contract in the source deck:
/// - `=` sets the current section (used for header state + PDF bookmarks)
/// - `==` sets the current topic (used for header state + PDF bookmarks)
/// - `===` starts a new slide and supplies that slide's visible title
/// - `====` creates a styled subheading inside a slide body
///
/// This means a deck file like `types.typ` can stay lightweight: no explicit
/// page breaks, no per-slide labels, and no manual running-header bookkeeping.

#let slides(
  title: [Untitled], // Long deck title shown on the title slide.
  subtitle: none, // Optional line below title on the title slide.
  short-title: auto, // Footer middle label. Example: "CS 3520" in `types.typ`.
  author: none, // Long author line on title slide.
  short-author: auto, // Footer short author; falls back to `author`.
  institute: none, // Long institute line on title slide.
  short-institute: none, // Footer short institute. Example: "Computing" in `types.typ`.
  date: none, // Title-slide date and footer-right date.
  color: rgb(0, 77, 0), // Primary accent for bars and heading accents.
  font-size: 8pt, // Base body size. Other sizes derive from this.
  text-font: "CMU Serif", // Main prose face.
  heading-font: "CMU Sans Serif", // Face for slide titles/chrome/headings.
  mono-font: "CMU Typewriter Text", // Face for code/raw blocks.
  math-font: "New Computer Modern Math", // Face for math equations.
  heading-size: auto, // Base heading size; `auto` derives from body size.
  mono-size: auto, // Base code size; `auto` derives from body size.
  chrome-size: auto, // Header/footer text size; `auto` derives from body size.
  aspect-ratio: "16-9", // "16-9" or "4-3" page geometry.
  doc, // The authored deck body (everything after `#show: slides.with(...)`).
) = {
  // Normalize short forms first so downstream rendering has one resolved value.
  // Practical example from `types.typ`:
  // - `title` is "Programming Languages" for the title page.
  // - `short-title` is "CS 3520" for compact footer display.
  // - `institute` is long-form department text, while `short-institute`
  //   is "Computing" in the footer-left cell.
  let short-title = if short-title == auto { title } else { short-title }
  let short-author = if short-author == auto { author } else { short-author }
  let short-institute = if short-institute == auto { institute } else { short-institute }

  // Geometry knobs used throughout the template.
  // These are the first values to tweak when the deck feels cramped/airy.
  let header-height = 1.4em // Running header bar height.
  let footer-height = 1.1em // Running footer bar height.
  let body-padding-x = 1em // Left/right inset for slide title band and body.
  let chrome-padding = 0.5em // Inner horizontal padding inside header/footer cells.
  let page-label-right-pad = 0.5em // Breathing room at the far-right footer edge.
  let frame-title-height = 1.9em // Height of each slide's title band.
  let body-top-gap = 0.3em // Gap between title band and slide body.
  let (page-width, page-height) = if aspect-ratio == "4-3" {
    (12cm, 9cm)
  } else {
    (16cm, 9cm)
  }

  // Typography scale: one base size, then derived "roles".
  // Keeping these derived values centralized avoids hunting through multiple
  // style calls when you change the visual scale of the deck.
  let text-size = font-size
  let resolved-heading-size = if heading-size == auto { text-size * 1.1 } else { heading-size }
  let resolved-mono-size = if mono-size == auto { text-size * 0.8 } else { mono-size }
  let resolved-chrome-size = if chrome-size == auto { text-size * 0.65 } else { chrome-size }

  let title-size = resolved-heading-size * 1.31

  // Title-slide scale has its own hierarchy because that page is a billboard.
  let title-slide-title-size = resolved-heading-size * 2.0
  let title-slide-subtitle-size = resolved-heading-size * 1.44
  let title-slide-author-size = resolved-heading-size * 0.91
  let title-slide-institute-size = resolved-heading-size * 0.73
  let title-slide-date-size = resolved-heading-size * 0.91
  let detail-heading-size = resolved-heading-size

  // Intra-group spacing on the title slide.
  // These control spacing *within* groups; inter-group spacing is controlled by
  // `v(...fr)` spacers inside `title-slide`.
  let title-subtitle-spacing = 1.0em
  let title-meta-spacing = 0.5em

  // Neutral tints used by header/footer/title bands.
  let title-color = color
  let title-bg = white.darken(10%)
  let header-right-bg = white.darken(15%)
  let footer-mid-bg = white.darken(5%)
  let footer-right-bg = white.darken(15%)

  // Reusable chrome helper: apply a consistent font role to header/footer text.
  let chrome-text(fill, body) = {
    set text(font: heading-font, size: resolved-chrome-size, fill: fill)
    body
  }

  // Header/footer cells all share the same structural pattern:
  // fixed height, background fill, inner padding, aligned text.
  let header-cell(bg, align-to, fill, body) = block(
    width: 100%,
    height: header-height,
    fill: bg,
    inset: (x: chrome-padding),
    align(align-to + horizon, chrome-text(fill, body)),
  )

  let footer-cell(bg, align-to, fill, body, inset: (x: chrome-padding)) = block(
    width: 100%,
    height: footer-height,
    fill: bg,
    inset: inset,
    align(align-to + horizon, chrome-text(fill, body)),
  )

  // Running header bar: left cell shows section, right cell shows topic.
  let header-bar(section-name: [], topic-name: []) = block(
    width: 100%,
    grid(
      columns: (1fr, 1fr),
      gutter: 0pt,
      header-cell(color, right, white, section-name),
      header-cell(header-right-bg, left, color, topic-name),
    ),
  )

  // Per-slide title strip directly under the running header.
  // This is intentionally separate from body content so changing body spacing
  // does not affect slide-title rhythm.
  let slide-title-band(slide-title) = block(
    width: 100%,
    height: frame-title-height,
    fill: title-bg,
    inset: (x: body-padding-x),
    align(left + horizon, [
      #set text(font: heading-font, size: title-size, weight: "medium", fill: title-color)
      #slide-title
    ]),
  )

  let slide(
    slide-title,
    slide-body,
    header-left: [],
    header-right: [],
    outline-section: none,
    outline-topic: none,
    break-before: false,
  ) = {
    // `slide` is the per-page compositor.
    // It applies running header state, injects optional outline markers, then
    // lays out a title band and body area.
    if break-before {
      pagebreak(weak: false)
    }
    set page(header: header-bar(section-name: header-left, topic-name: header-right))
    // Outline markers are inserted as hidden heading semantics so the PDF has
    // section/topic bookmarks without showing those headings in slide content.
    if outline-section != none {
      heading(level: 1, outlined: true, bookmarked: true)[#outline-section]
    }
    if outline-topic != none {
      heading(level: 2, outlined: true, bookmarked: true)[#outline-topic]
    }
    slide-title-band(slide-title)
    v(body-top-gap)
    block(
      width: 100%,
      inset: (x: body-padding-x),
      slide-body,
    )
  }

  let title-slide(header-left: [], header-right: []) = {
    // Title page uses three logical groups:
    // 1) title/subtitle, 2) author/institute, 3) date.
    // Vertical `fr` spacers between groups control their relative separation.
    set page(header: header-bar(section-name: header-left, topic-name: header-right))
    let group-title = stack(
      dir: ttb,
      spacing: title-subtitle-spacing,
      text(font: heading-font, size: title-slide-title-size, weight: "medium", fill: title-color)[#title],
      if subtitle != none {
        text(font: heading-font, size: title-slide-subtitle-size, fill: title-color)[#subtitle]
      } else {
        []
      },
    )
    let group-author = stack(
      dir: ttb,
      spacing: title-meta-spacing,
      if author != none {
        text(font: heading-font, size: title-slide-author-size, weight: "medium")[#author]
      } else {
        []
      },
      if institute != none {
        text(font: heading-font, size: title-slide-institute-size)[#institute]
      } else {
        []
      },
    )
    let group-date = if date != none {
      text(font: heading-font, size: title-slide-date-size)[#date]
    } else {
      []
    }
    block(
      width: 100%,
      height: 100%,
      [
        #set align(center)
        #stack(
          dir: ttb,
          spacing: 0pt,
          v(1fr),
          block(width: 100%, group-title),
          v(0.5fr),
          block(width: 100%, group-author),
          v(0.5fr),
          block(width: 100%, group-date),
          v(1fr),
        )
      ],
    )
  }

  // Global text defaults for the deck body.
  // - Main text uses the configured text face.
  // - Equation math uses the configured math face.
  // - Raw/code blocks use the configured monospaced role.
  set text(size: text-size, font: text-font, style: "normal")
  show math.equation: set text(font: math-font)
  show raw: set text(font: mono-font, size: resolved-mono-size)
  show raw.where(block: true): it => block(inset: (left: 1em), it)
  set par(leading: 0.6em)

  // Heading behavior by level.
  // Levels 1-2 carry structure state and bookmarks; they are hidden visually.
  show heading.where(level: 1): set block(above: 0pt, below: 0pt)
  show heading.where(level: 1): set text(size: 0pt)
  show heading.where(level: 2): set block(above: 0pt, below: 0pt)
  show heading.where(level: 2): set text(size: 0pt)

  // Level 3 headings are consumed as slide boundaries/titles, not printed inline.
  show heading.where(level: 3): set heading(outlined: false)
  show heading.where(level: 3): it => []

  // Level 4 headings are visible subheadings inside a slide.
  show heading.where(level: 4): it => {
    v(0.3em)
    block(
      width: 100%,
      [
        #set text(font: heading-font, size: detail-heading-size, weight: "bold", fill: title-color)
        #it.body
      ],
    )
    v(0.2em)
  }

  // Transform linear document content into explicit slide pages.
  //
  // Why this parser exists:
  // Authoring stays simple (`=`, `==`, `===`), while runtime keeps enough state
  // to render running headers and emit PDF bookmarks at section/topic changes.
  let render-slides(body) = {
    let rendered = ()
    let section-state = []
    let topic-state = []
    let slide-section = []
    let slide-topic = []
    let outlined-section = none
    let outlined-topic = none
    let current-title = none
    let current-body = ()

    // Walk the top-level document stream once and build slide objects.
    for child in body.children {
      if child.func() == heading and child.depth == 1 {
        // New section resets topic state.
        section-state = child.body
        topic-state = []
      } else if child.func() == heading and child.depth == 2 {
        // Topic update within current section.
        topic-state = child.body
      } else if child.func() == heading and child.depth == 3 {
        // Starting a new slide: flush the previous one first.
        if current-title != none {
          let body-content = [#for part in current-body { part }]
          // Emit outline entry only when section/topic actually changes.
          let outline-section = if slide-section != [] and slide-section != outlined-section {
            outlined-section = slide-section
            outlined-topic = none
            slide-section
          } else {
            none
          }
          let outline-topic = if slide-topic != [] and slide-topic != outlined-topic {
            outlined-topic = slide-topic
            slide-topic
          } else {
            none
          }

          let _ = rendered.push(slide(
            current-title,
            body-content,
            header-left: slide-section,
            header-right: slide-topic,
            outline-section: outline-section,
            outline-topic: outline-topic,
            break-before: true,
          ))
        }
        current-title = child.body
        slide-section = section-state
        slide-topic = topic-state
        current-body = ()
      } else if current-title != none {
        // Regular content belongs to the currently open slide.
        let _ = current-body.push(child)
      }
    }

    // Flush final slide after loop.
    if current-title != none {
      let body-content = [#for part in current-body { part }]
      let outline-section = if slide-section != [] and slide-section != outlined-section {
        outlined-section = slide-section
        outlined-topic = none
        slide-section
      } else {
        none
      }
      let outline-topic = if slide-topic != [] and slide-topic != outlined-topic {
        outlined-topic = slide-topic
        slide-topic
      } else {
        none
      }

      let _ = rendered.push(slide(
        current-title,
        body-content,
        header-left: slide-section,
        header-right: slide-topic,
        outline-section: outline-section,
        outline-topic: outline-topic,
        break-before: true,
      ))
    }

    {
      // The deck always opens with a first-class title page.
      title-slide()
      for part in rendered {
        part
      }
    }
  }

  // Page frame: full-width header/footer "chrome", explicit body insets.
  // Footer is context-aware so it can compute "current / total" page numbers.
  set page(
    width: page-width,
    height: page-height,
    margin: (top: header-height, bottom: footer-height, x: 0pt),
    header-ascent: 0%,
    footer-descent: 0%,
    header: header-bar(),
    footer: context {
      let page-num = counter(page).get().at(0)
      let total-pages = counter(page).final().at(0)
      // Reserve enough width for the widest possible page label ("n/N") so the
      // date stays fixed and does not drift as page numbers grow.
      let max-page-label-width = 0pt
      for i in range(1, total-pages + 1) {
        let label-width = measure([#i/#total-pages]).width
        if label-width > max-page-label-width {
          max-page-label-width = label-width
        }
      }

      // Footer-left identity rule:
      // prefer short forms when provided, then fall back to long forms.
      // In `types.typ`, this resolves to: "Dr Russ Ross (Computing)".
      let author-institute = if short-author != none and short-institute != none {
        [#short-author (#short-institute)]
      } else if short-author != none {
        short-author
      } else if short-institute != none {
        short-institute
      } else if author != none and institute != none {
        [#author (#institute)]
      } else if author != none {
        author
      } else {
        []
      }

      block(
        width: 100%,
        grid(
          columns: (1fr, 1fr, 1fr),
          gutter: 0pt,
          footer-cell(color, center, white, author-institute),
          // Footer-middle typically shows `short-title`.
          // In `types.typ`, this is "CS 3520" instead of the full title.
          footer-cell(footer-mid-bg, center, color, if short-title != none { short-title } else { [] }),
          footer-cell(
            footer-right-bg,
            center,
            color,
            grid(
              columns: (1fr, auto),
              gutter: 0pt,
              if date != none { align(center, date) } else { [] },
              box(
                width: max-page-label-width,
                align(right + horizon, [#page-num/#total-pages]),
              ),
            ),
            inset: (left: chrome-padding, right: page-label-right-pad),
          ),
        ),
      )
    },
  )

  // Final render: title page plus parsed slide content.
  render-slides(doc)
}

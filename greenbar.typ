/// Slide template for "authored-content-first" decks.
///
/// The design goal is: authors mostly write headings and content, while this
/// template handles page bars, title pages, footer metadata, and outline
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
  text-font: "CMU Serif", // Main prose face.
  heading-font: "CMU Sans Serif", // Face for slide titles, bars, and headings.
  mono-font: "CMU Typewriter Text", // Face for code/raw blocks.
  math-font: "New Computer Modern Math", // Face for math equations.
  text-size: 9pt, // Base body size. Other sizes derive from this.
  mono-scale: auto, // Inline code size relative to surrounding text size.
  block-mono-scale: auto, // Block code size relative to the base body size.
  aspect-ratio: "16-9", // "16-9" or "4-3" page geometry.
  doc, // The authored deck body (everything after `#show: slides.with(...)`).
) = {
  // Author-facing API:
  // parameters to `slides(...)` are the intended deck-level customization
  // surface; literal sizes and spacing in the helpers below are template
  // layout policy.
  //
  // Layout guide for readers:
  // - title page typography and spacing: `title-page(...)`
  // - regular slide title band: `slide-title-bar(...)`
  // - regular slide body inset and gap: `slide(...)`
  // - header/footer bar sizing and padding: `header-cell(...)`,
  //   `footer-cell(...)`, and `set page(...)`
  // - footer content layout: the footer grid inside `set page(...)`
  //
  // Resolve author-facing `auto` options first so downstream rendering has one
  // value per setting.
  // Practical example from `types.typ`:
  // - `title` is "Programming Languages" for the title page.
  // - `short-title` is "CS 3520" for compact footer display.
  // - `institute` is long-form department text, while `short-institute`
  //   is "Computing" in the footer-left cell.
  let short-title = if short-title == auto { title } else { short-title }
  let short-author = if short-author == auto { author } else { short-author }
  let short-institute = if short-institute == auto { institute } else { short-institute }
  let mono-scale = if mono-scale == auto { 1.0 } else { mono-scale }
  let block-mono-scale = if block-mono-scale == auto { 0.8 } else { block-mono-scale }

  // Page canvas selected from the deck's aspect ratio.
  let (page-width, page-height) = if aspect-ratio == "4-3" {
    (12cm, 9cm)
  } else {
    (16cm, 9cm)
  }

  // Shared typography used in the regular slide title band.
  // Slide-title text and inline raw inside that title band share this size.
  let title-size = text-size * 1.3

  // Shared colors used by the title band and header/footer bars.
  let title-color = color
  let title-bg = white.darken(10%)
  let header-right-bg = white.darken(15%)
  let footer-mid-bg = white.darken(5%)
  let footer-right-bg = white.darken(15%)

  // Header and footer text styling used in the bars on each page.
  let bar-text(fill, body) = {
    set text(font: heading-font, size: text-size * 0.6, fill: fill)
    body
  }

  // Header and footer cells share the same block structure: fixed height,
  // background fill, horizontal inset, and aligned text.
  let header-cell(bg, align-to, fill, body) = block(
    width: 100%,
    height: 1.2em,
    fill: bg,
    inset: (x: 0.5em),
    align(align-to + horizon, bar-text(fill, body)),
  )

  let footer-cell(bg, align-to, fill, body, inset: (x: 0.5em)) = block(
    width: 100%,
    height: 1.2em,
    fill: bg,
    inset: inset,
    align(align-to + horizon, bar-text(fill, body)),
  )

  // Header bar visible at the top of each page. The left cell shows the
  // section and the right cell shows the topic.
  let header-bar(section-name: [], topic-name: []) = block(
    width: 100%,
    grid(
      columns: (1fr, 1fr),
      gutter: 0pt,
      header-cell(color, right, white, section-name),
      header-cell(header-right-bg, left, color, topic-name),
    ),
  )

  // Title page layout used on the first page of the deck.
  // The page is arranged in three vertical groups: title/subtitle,
  // author/institute, and date.
  let title-page(header-left: [], header-right: []) = {
    set page(header: header-bar(section-name: header-left, topic-name: header-right))
    let group-title = stack(
      dir: ttb,
      spacing: 1.0em,
      text(font: heading-font, size: text-size * 2.0, weight: "medium", fill: title-color)[#title],
      if subtitle != none {
        text(font: heading-font, size: text-size * 1.44, fill: title-color)[#subtitle]
      } else {
        []
      },
    )
    let group-author = stack(
      dir: ttb,
      spacing: 0.5em,
      if author != none {
        text(font: heading-font, size: text-size * 0.91, weight: "medium")[#author]
      } else {
        []
      },
      if institute != none {
        text(font: heading-font, size: text-size * 0.73)[#institute]
      } else {
        []
      },
    )
    let group-date = if date != none {
      text(font: heading-font, size: text-size * 0.91)[#date]
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

  // Regular slide title band directly below the header.
  // This band is separate from the slide body so the title rhythm stays stable
  // even when body layout changes.
  let slide-title-bar(slide-title) = block(
    width: 100%,
    height: 1.6em,
    fill: title-bg,
    inset: (x: 1.0em),
    align(left + horizon, [
      #set text(font: heading-font, size: title-size, weight: "medium", fill: title-color)
      #show raw: it => text(font: mono-font, size: mono-scale * 1em, it)
      #slide-title
    ]),
  )

  // Regular slide layout: header, title band, gap, then body.
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
    slide-title-bar(slide-title)
    v(0.5em)
    block(
      width: 100%,
      inset: (x: 1.0em),
      slide-body,
    )
  }

  // Global typography and heading rules applied to authored slide content.
  // - Main text uses the configured text face and base size.
  // - Equation math uses the configured math face at the base size.
  // - Inline raw/code scales relative to the surrounding text via `mono-scale`.
  // - Block raw/code scales from the base body size via `block-mono-scale`.
  set text(size: text-size, font: text-font, style: "normal")
  show math.equation: set text(font: math-font, size: text-size)
  show raw.where(block: false): set text(font: mono-font, size: mono-scale * 1em)
  show raw.where(block: true): set text(font: mono-font, size: text-size * block-mono-scale)
  show raw.where(block: true): it => block(inset: (left: 1.6em), it)
  set par(leading: 0.5em)

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
  show heading.where(level: 4): set heading(outlined: false, bookmarked: false)
  show heading.where(level: 4): it => {
    v(0.3em)
    block(
      width: 100%,
      [
        #set text(font: heading-font, size: text-size, weight: "bold", fill: title-color)
        #it.body
      ],
    )
    v(0.2em)
  }

  // Document parser: transform the authored heading stream into explicit slide
  // pages while tracking section/topic state for headers and PDF bookmarks.
  let build-slide-pages(body) = {
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
      title-page()
      for part in rendered {
        part
      }
    }
  }

  // Page frame shared by the title page and regular slides.
  // The footer computes "current / total" page numbers with Typst context.
  set page(
    width: page-width,
    height: page-height,
    margin: (top: 1.2em, bottom: 1.2em, x: 0pt),
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
            inset: (left: 0.5em, right: 0.5em),
          ),
        ),
      )
    },
  )

  // Final render: title page plus parsed slide content.
  build-slide-pages(doc)
}

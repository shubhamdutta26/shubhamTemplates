// Define a function 'article' to configure the document
#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: "Roboto Slab",
  fontsize: 11pt,
  title-size: 25pt,
  subtitle-size: 20pt,
  heading-family: "Roboto",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: rgb("#000000"),  // black
  heading-line-height: 1pt,
  sectionnumbering: none,
  pagenumbering: "1",
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  title-color: rgb("#419D78"),   // forest green
  subtitle-color: rgb("#2D3047"), // deep navy
  author-color: rgb("#2D3047"), // deep navy
  date-color: rgb("#2D3047"), // deep navy
  doc, // document content
) = {

  // Set general page settings
  set page(
    paper: paper,
    margin: margin,
    numbering: pagenumbering,
  )

  // Default text and paragraph settings
  set par(justify: true)
  set text(
    lang: lang,
    region: region,
    font: font,
    size: fontsize,
  )

  // Set raw block font
  show raw: set text(ligatures: true, font: "JetBrains Mono")

  // Section heading numbering
  set heading(numbering: sectionnumbering)

  // Title + Subtitle block
  if title != none {
    align(left)[
      #block(inset: 0em)[
        #set par(leading: heading-line-height)
        
        // Custom heading style
        #if (
          heading-family != none or heading-weight != "bold" or heading-style != "normal"
          or heading-color != rgb("#000000") // Default black color
        ) {
          set text(
            font: heading-family,
            weight: heading-weight,
            style: heading-style,
            fill: title-color,
          )
          text(size: title-size)[#title]
          if subtitle != none {
            block(above: 0em)[]
            set text(fill: subtitle-color)
            text(size: subtitle-size)[#subtitle]
          }
        } else {
          // Fallback heading style
          set text(fill: title-color)
          text(weight: "bold", size: title-size)[#title]
          if subtitle != none {
            block(above: 0em)[]
            set text(fill: subtitle-color)
            text(weight: "bold", size: subtitle-size)[#subtitle]
          }
        }
      ]
    ]
  }

  // Authors block (up to 3 columns)
  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
        align(left)[
          #set text(fill: author-color)
          #author.name \
          #author.affiliation \
          #author.email
        ]
      )
    )
  }

  // Date block
  if date != none {
    align(left)[
      #block(inset: 0em)[
        #set text(fill: date-color)
        #date
      ]
    ]
  }

  // Abstract block
  if abstract != none {
    block(inset: 2em)[
      #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  // Table of Contents (TOC) block
  if toc {
    let title = if toc_title == none { auto } else { toc_title }
    block(above: 0em, below: 2em)[
      #outline(
        title: title,
        depth: toc_depth,
        indent: toc_indent,
      )
    ]
  }

  // Columns layout
  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

// Default table settings
#set table(
  inset: 6pt,
  stroke: none,
)

// Actual document start: connect Quarto variables to Typst
#show: doc => article(
$if(title)$
  title: [$title$],
$endif$
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(by-author)$
  authors: (
$for(by-author)$
$if(it.name.literal)$
    (
      name: [$it.name.literal$],
      affiliation: [$for(it.affiliations)$$it.name$$sep$, $endfor$],
      email: [$it.email$],
    ),
$endif$
$endfor$
  ),
$endif$
$if(date)$
  date: [$date$],
$endif$
$if(lang)$
  lang: "$lang$",
$endif$
$if(region)$
  region: "$region$",
$endif$
$if(abstract)$
  abstract: [$abstract$],
  abstract-title: "$labels.abstract$",
$endif$
$if(margin)$
  margin: ($for(margin/pairs)$$margin.key$: $margin.value$,$endfor$),
$endif$
$if(papersize)$
  paper: "$papersize$",
$endif$
$if(mainfont)$
  font: ("$mainfont$"),
$elseif(brand.typography.base.family)$
  font: $brand.typography.base.family$,
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$elseif(brand.typography.base.size)$
  fontsize: $brand.typography.base.size$,
$endif$

// Heading styles
$if(title)$
$if(brand.typography.headings.family)$
  heading-family: $brand.typography.headings.family$,
$endif$
$if(brand.typography.headings.weight)$
  heading-weight: $brand.typography.headings.weight$,
$endif$
$if(brand.typography.headings.style)$
  heading-style: "$brand.typography.headings.style$",
$endif$
$if(brand.typography.headings.decoration)$
  heading-decoration: "$brand.typography.headings.decoration$",
$endif$
$if(brand.typography.headings.color)$
  heading-color: $brand.typography.headings.color$,
$endif$
$if(brand.typography.headings.line-height)$
  heading-line-height: $brand.typography.headings.line-height$,
$endif$
$endif$

// Section numbering
$if(section-numbering)$
  sectionnumbering: "$section-numbering$",
$endif$

// Page numbering
  pagenumbering: $if(page-numbering)$"$page-numbering$"$else$none$endif$,

// TOC options
$if(toc)$
  toc: $toc$,
$endif$
$if(toc-title)$
  toc_title: [$toc-title$],
$endif$
$if(toc-indent)$
  toc_indent: $toc-indent$,
$endif$
  toc_depth: $toc-depth$,

// Columns
  cols: $if(columns)$$columns$$else$1$endif$,

  doc, // body of the document
)

// Render optional includes and body
$for(header-includes)$
$header-includes$
$endfor$

$for(include-before)$
$include-before$
$endfor$

$body$

$notes.typ()$
$biblio.typ()$

$for(include-after)$
$include-after$
$endfor$

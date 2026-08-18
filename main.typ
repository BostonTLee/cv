#let cv-file = sys.inputs.at("cv-file", default: "cv.yaml")
#let cv = yaml(cv-file)

#let navy = rgb("1f4e79")
#let muted = rgb("555555")
#let rule-color = rgb("333333")
#let month-names = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

#let date-label(value) = {
  let raw = str(value)
  let month = int(raw.slice(5, 7))
  month-names.at(month - 1) + " " + raw.slice(0, 4)
}

#let date-range(start, end: none) = {
  date-label(start) + " – " + if end == none { "Present" } else { date-label(end) }
}

#let section(title, body) = {
  block(above: 0.45em, below: 0.45em, width: 100%)[
    #text(size: 14pt)[#upper(title.slice(0, 1))#text(size: 10pt)[#upper(title.slice(1))]]
    #v(0.2em)
    #line(length: 100%, stroke: 0.6pt + rule-color)
  ]
  body
}

#let entry-heading(left-content, right-content: none) = {
  block(above: 0.2em, below: 0.25em, breakable: false)[
    #grid(
      columns: (1fr, auto),
      gutter: 0.5em,
      align: (left, right),
      text(weight: "bold")[#left-content],
      if right-content != none { text(weight: "bold")[#right-content] },
    )
  ]
}

#let bullet-list(items, tight: true) = {
  list(
    tight: tight,
    marker: [•],
    indent: 1.1em,
    body-indent: 0.35em,
    ..items.map(item => [#item]),
  )
}

#set page(
  paper: "us-letter",
  margin: (x: 0.85in, y: 0.45in),
)
#set text(font: "Latin Modern Roman", size: 11pt, lang: "en")
#set par(justify: false, leading: 0.5em)
#set block(spacing: 0pt)

#grid(
  columns: (1fr, auto),
  gutter: 1em,
  align(left + top)[
    #text(size: 18pt)[#cv.profile.name]
    #linebreak()
    #cv.profile.phone #linebreak()
    #cv.profile.email
  ],
  align(right + top)[
    #v(1.5em)
    #text(size: 9pt, fill: blue)[#link(cv.profile.linkedin)[#cv.profile.linkedin]]
    #linebreak()
    #text(size: 9pt, fill: blue)[#link(cv.profile.site)[#cv.profile.site]]
  ],
)

#v(0.5em)
#section("Employment", {
  for job in cv.work {
    entry-heading(
      [#job.title #linebreak() #job.employer],
      right-content: [#date-range(job.start_date, end: job.at("end_date", default: none)) #linebreak() #job.location],
    )
    v(0.25em)
    bullet-list(
      job.description.map(item => item.content),
    )
    v(0.5em)
  }
})

#section("Education", {
  for school in cv.education {
    entry-heading(
      [#school.institution #linebreak() #school.degree -- GPA: #school.gpa#if school.honors != none [, #text(style: "italic", weight: "regular")[#school.honors]]],
      right-content: [#date-range(school.start_date, end: school.end_date) #linebreak() #school.location],
    )
  }
})

#section("Skills", {
  grid(
    columns: (auto, 1fr),
    column-gutter: 0.5em,
    row-gutter: 0.5em,
    text(weight: "bold")[Languages:],
    cv.languages.join(", "),
    text(weight: "bold")[Tools:],
    cv.tools.join(", "),
  )
})

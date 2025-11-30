//! Markdown parsing and rendering support.
//!
//! A Markdown document consists of a series of blocks. Depending on its type,
//! each block may contain other blocks, inline content, or nothing. The
//! supported blocks are as follows:
//!
//! - **List** - a sequence of list items of the same type.
//!
//! - **List item** - unordered list items start with `-`, `*`, or `+` followed
//!   by a space. Ordered list items start with a number between 0 and
//!   999,999,999, followed by a `.` or `)` and a space. The number of an
//!   ordered list item only matters for the first item in the list (to
//!   determine the starting number of the list). All subsequent ordered list
//!   items will have sequentially increasing numbers.
//!
//!   All list items may contain block content. Any content indented at least as
//!   far as the end of the list item marker (including the space after it) is
//!   considered part of the list item.
//!
//!   Lists which have no blank lines between items or between direct children
//!   of items are considered _tight_, and direct child paragraphs of tight list
//!   items are rendered without `<p>` tags.
//!
//! - **Table** - a sequence of adjacent table row lines, where each line starts
//!   and ends with a `|`, and cells within the row are delimited by `|`s.
//!
//!   The first or second row of a table may be a _header delimiter row_, which
//!   is a row consisting of cells of the pattern `---` (for unset column
//!   alignment), `:--` (for left alignment), `:-:` (for center alignment), or
//!   `--:` (for right alignment). The number of `-`s must be at least one, but
//!   is otherwise arbitrary. If there is a row just before the header delimiter
//!   row, it becomes the header row for the table (a table need not have a
//!   header row at all).
//!
//! - **Heading** - a sequence of between 1 and 6 `#` characters, followed by a
//!   space and further inline content on the same line.
//!
//! - **Code block** - a sequence of at least 3 `` ` `` characters (a _fence_),
//!   optionally followed by a "tag" on the same line, and continuing until a
//!   line consisting only of a closing fence whose length matches the opening
//!   fence, or until the end of the containing block.
//!
//!   The content of a code block is not parsed as inline content. It is
//!   included verbatim in the output document (minus leading indentation up to
//!   the position of the opening fence).
//!
//! - **Blockquote** - a sequence of lines preceded by `>` characters.
//!
//! - **Paragraph** - ordinary text, parsed as inline content, ending with a
//!   blank line or the end of the containing block.
//!
//!   Paragraphs which are part of another block may be "lazily" continued by
//!   subsequent paragraph lines even if those lines would not ordinarily be
//!   considered part of the containing block. For example, this is a single
//!   list item, not a list item followed by a paragraph:
//!
//!   ```markdown
//!   - First line of content.
//!   This content is still part of the paragraph,
//!   even though it isn't indented far enough.
//!   ```
//!
//! - **Thematic break** - a line consisting of at least three matching `-`,
//!   `_`, or `*` characters and, optionally, spaces.
//!
//! Indentation may consist of spaces and tabs. The use of tabs is not
//! recommended: a tab is treated the same as a single space for the purpose of
//! determining the indentation level, and is not recognized as a space for
//! block starters which require one (for example, `-` followed by a tab is not
//! a valid list item).
//!
//! The supported inlines are as follows:
//!
//! - **Link** - of the format `[text](target)`. `text` may contain inline
//!   content. `target` may contain `\`-escaped characters and balanced
//!   parentheses.
//!
//! - **Autolink** - an abbreviated link, of the format `<target>`, where
//!   `target` serves as both the link target and text. `target` may not
//!   contain spaces or `<`, and any `\` in it are interpreted literally (not as
//!   escapes). `target` is expected to be an absolute URI: an autolink will not
//!   be recognized unless `target` starts with a URI scheme followed by a `:`.
//!
//!   For convenience, autolinks may also be recognized in plain text without
//!   any `<>` delimiters. Such autolinks are restricted to start with `http://`
//!   or `https://` followed by at least one other character, not including any
//!   trailing punctuation after the link.
//!
//! - **Image** - a link directly preceded by a `!`. The link text is
//!   interpreted as the alt text of the image.
//!
//! - **Emphasis** - a run of `*` or `_` characters may be an emphasis opener,
//!   closer, or both. For `*` characters, the run may be an opener as long as
//!   it is not directly followed by a whitespace character (or the end of the
//!   inline content) and a closer as long as it is not directly preceded by
//!   one. For `_` characters, this rule is strengthened by requiring that the
//!   run also be preceded by a whitespace or punctuation character (for
//!   openers) or followed by one (for closers), to avoid mangling `snake_case`
//!   words.
//!
//!   The rule for emphasis handling is greedy: any run that can close existing
//!   emphasis will do so, otherwise it will open emphasis. A single run may
//!   serve both functions: the middle `**` in the following example both closes
//!   the initial emphasis and opens a new one:
//!
//!   ```markdown
//!   *one**two*
//!   ```
//!
//!   A single `*` or `_` is used for normal emphasis (HTML `<em>`), and a
//!   double `**` or `__` is used for strong emphasis (HTML `<strong>`). Even
//!   longer runs may be used to produce further nested emphasis (though only
//!   `***` and `___` to produce `<em><strong>` is really useful).
//!
//! - **Code span** - a run of `` ` `` characters, terminated by a matching run
//!   or the end of inline content. The content of a code span is not parsed
//!   further.
//!
//! - **Text** - normal text is interpreted as-is, except that `\` may be used
//!   to escape any punctuation character, preventing it from being interpreted
//!   according to other syntax rules. A `\` followed by a line break within a
//!   paragraph is interpreted as a hard line break.
//!
//!   Any null bytes or invalid UTF-8 bytes within text are replaced with Unicode
//!   replacement characters, `U+FFFD`.

const std = @import("std");

pub const Document = @import("markdown/Document.zig");
pub const Parser = @import("markdown/Parser.zig");
pub const Renderer = @import("markdown/renderer.zig").Renderer;
pub const renderNodeInlineText = @import("markdown/renderer.zig").renderNodeInlineText;
pub const fmtHtml = @import("markdown/renderer.zig").fmtHtml;

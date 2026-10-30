# Git

Never run `git commit` unless I ask for it in that specific request. This applies to every repo.
Finish the work, report what changed, and leave it in the working tree for me to stage and commit.

- Approval does not carry over. If I ask for a commit once, that covers that commit only — the
  next one needs its own ask. The same goes for `git push`, and for pushing to `main` especially.
- "Create a branch" means create the branch and nothing more. It is not permission to commit onto it.
- Finishing a task is not a reason to commit it, and don't offer a commit as the obvious next step.

# Code conventions

Follow the conventions the repo already sets, and go looking for them before writing code rather
than assuming defaults. Check `.editorconfig` first — including the nearest one in a parent
directory, since `root = true` marks where the chain stops.

- Honour `max_line_length`. It is often 180. Do not wrap a line that fits within it: reflowing
  code or comments at 80, 100 or 120 out of habit is wrong when the file allows 180.
- Also match `indent_style` and `indent_size` per file type (tabs and spaces often differ between
  the source and the `.tf`/`.yaml` files in the same repo), `end_of_line`, `charset` and
  `insert_final_newline`.
- Where `.editorconfig` is silent, copy the surrounding file's existing style instead of
  introducing my own.

# Code comments

Don't over-comment. Code that is easy to follow needs no comment, and a comment restating what
the next line plainly does is noise I will delete.

- Comment only what the code cannot say itself: a non-obvious *why*, a constraint from outside
  the file, a workaround, a decision that looks wrong until explained.
- Put rationale in the reply or the PR description by default, not inline.
- Match the density of the surrounding code rather than my prose. Terse config files
  (CI workflows, manifests) should read as configuration, not documentation.

<!-- postman-cli:installation:start -->
Postman CLI is installed on this device, and can be used for API Engineering work.
<!-- postman-cli:installation:end -->

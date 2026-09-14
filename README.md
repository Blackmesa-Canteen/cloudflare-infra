# cloudflare-infra

Cloudflare resources managed as code, changed only through reviewed PRs and
applied by GitHub Actions — no dashboard click-ops for anything in here.

Currently manages one thing: the R2 bucket used to sync an Obsidian vault
(via the Self-hosted LiveSync plugin). Laid out so more resources can be
added as their own stack later without restructuring anything.

## Security

Public repo (needed for free GitHub branch protection), but nothing
sensitive lives in it — IDs aren't credentials, state lives in R2 not git,
secrets exist only as GitHub Actions secrets.

- Branch protection on `main`: PRs required, `Plan` + both `Security` jobs
  required, force-push/delete disabled, enforced for the owner too.
- `sha_pinning_required` on — every action pinned to a commit SHA;
  Dependabot bumps them.
- Fork PR workflow runs require maintainer approval
  (`all_external_contributors`).
- Default workflow token permissions are read-only; each job further scopes
  its own `permissions:`.
- `persist-credentials: false` on every checkout step.

## Layout

```
modules/
  r2-bucket/       reusable: bucket + lifecycle rule + optional CORS
stacks/
  notes-sync/       the LiveSync bucket — the only stack today
.github/
  workflows/
    terraform-notes-sync.yml   plan on PR, gated apply on merge to main
    security.yml               gitleaks + a Terraform config scan
  dependabot.yml    weekly PRs for the terraform provider + Actions versions
```

Each stack under `stacks/` owns its own state file (same state bucket,
different `key`) and its own workflow, scoped to its own path and its own
API token. See "Adding a new stack" below.

## Bootstrap (one-time, manual — the only click-ops in this repo)

Terraform needs somewhere to put its state file before it can manage
anything else, so this one step can't be done by Terraform itself.

1. **Create a small R2 bucket by hand** in the Cloudflare dashboard, e.g.
   `tfstate`. It holds only `.tfstate` files — nothing else should ever go
   in it.

2. **Create an R2 API token pair** (dashboard → R2 → Manage R2 API Tokens →
   Create API Token), scoped to Object Read & Write on just the `tfstate`
   bucket. This is the *S3-compatible* Access Key ID / Secret Access Key
   Terraform's backend uses to read/write the state file — a different
   credential type from the Cloudflare API token below.

3. **Create a Cloudflare API token** (dashboard → My Profile → API Tokens),
   scoped to **Account → R2 → Edit** on this account only. No account-wide
   admin, no token-creation permission. This is what the `cloudflare`
   Terraform provider uses to actually manage the bucket.

4. **Update the two placeholders** in
   [`stacks/notes-sync/providers.tf`](stacks/notes-sync/providers.tf) —
   `REPLACE_ME_TFSTATE_BUCKET` (the bucket from step 1) and
   `REPLACE_ME_ACCOUNT_ID` (your Cloudflare account ID) — then commit that
   change through a normal PR. Neither value is a secret; they're just
   identifiers, safe to commit.

5. **In this repo's GitHub settings**, add:
   - Repository secrets (Settings → Secrets and variables → Actions →
     Repository secrets): `R2_TFSTATE_ACCESS_KEY_ID`,
     `R2_TFSTATE_SECRET_ACCESS_KEY` (from step 2), `CLOUDFLARE_API_TOKEN`
     (from step 3).
   - Repository variable: `CLOUDFLARE_ACCOUNT_ID`.
   - An **Environment** named `infra-apply`, with "Required reviewers" set
     to yourself. It holds no secrets of its own — its only job is to make
     `terraform apply` pause for a manual approval click in the Actions UI
     before it ever touches Cloudflare, even though it's triggered
     automatically on merge to `main`.

6. ~~Turn on branch protection~~ — already configured, see "Security" above.

After this, everything else — creating the bucket, changing its lifecycle
rule, adding a future stack — goes through a PR with a visible plan, not the
dashboard.

## How changes flow

1. Edit `.tf` files on a branch, open a PR.
2. `Terraform (notes-sync)` runs `fmt`, `validate`, and `plan`, and posts
   the plan as a PR comment. `Security` runs gitleaks and a Terraform config
   scan. Both are required checks.
3. Merge. `apply` runs, but pauses in the Actions tab for your manual
   approval (the `infra-apply` Environment gate) before it actually calls
   the Cloudflare API.

## Adding a new stack

Copy the shape of `stacks/notes-sync/`: its own `providers.tf` (own state
`key`), its own `variables.tf`/`main.tf`, reusing a module under `modules/`
if one fits. Give it its own workflow (copy `terraform-notes-sync.yml`,
change the `working-directory`) and its **own** scoped API token/secret
rather than widening an existing one — keeps a leaked or misused token
limited to the one stack it belongs to. Don't add a `paths:` filter to its
`Plan` trigger if `Plan` is a required check — same reason the notes-sync
one doesn't have one (a path-filtered required check never reports, so
never merges, on a PR that doesn't touch that path).

## Notes-sync bucket — using it with Obsidian

Once the bucket exists (`terraform apply` has run), generate a *separate*
R2 API token scoped to just that bucket for the Obsidian **Self-hosted
LiveSync** plugin to use directly. That credential is app-side only — paste
it into the plugin's S3/R2 settings on each device, never into GitHub or
this repo. Only the bucket's existence and configuration are managed here,
not the app's own sync credentials.
